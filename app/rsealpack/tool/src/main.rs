use aes_gcm::{Aes256Gcm, Key, Nonce, KeyInit};
use aes_gcm::aead::{Aead, OsRng, consts::U12};
use base64::{Engine as _, engine::general_purpose};
use clap::Parser;
use rand::RngCore;
use scrypt::scrypt;
use sha2::{Sha256, Digest};
use std::fs;
use std::env;

const RUST_TEMPLATE: &str = r#"use aes_gcm::{Aes256Gcm, Key, Nonce, KeyInit};
use aes_gcm::aead::{Aead, consts::U12};
use base64::{Engine as _, engine::general_purpose};
use scrypt::scrypt;
use sha2::{Sha256, Digest};
use std::env;
use std::fs;
use std::process::{self, Command, Stdio};
use std::io::Write;
use std::os::unix::io::FromRawFd;
use which::which;

const ENC_B64: &str = "{{ enc_b64 }}";
const SALT_B64: &str = "{{ salt_b64 }}";
const NONCE_B64: &str = "{{ nonce_b64 }}";
const INTERP: &[&str] = &[{{ interp_list }}];
const ENV_VAR: &str = "{{ env_var }}";
const DEFAULT_PASSWORD: &str = "{{ default_password }}";

// インタープリターの期待値（暗号化済み）
const EXPECTED_PATH_ENC_B64: &str = "{{ expected_path_enc_b64 }}";
const EXPECTED_HASH_ENC_B64: &str = "{{ expected_hash_enc_b64 }}";

fn kdf(password: &[u8], salt: &[u8]) -> Result<[u8; 32], Box<dyn std::error::Error>> {
    let mut key = [0u8; 32];
    scrypt(password, salt, &scrypt::Params::new(15, 8, 1, 32)?, &mut key)?;
    Ok(key)
}

fn decrypt(password: &[u8], enc: &[u8], salt: &[u8], nonce: &[u8]) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    let key = kdf(password, salt)?;
    let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(&key));
    let nonce = Nonce::<U12>::from_slice(nonce);
    
    cipher.decrypt(nonce, enc)
        .map_err(|_| "decryption failed (bad password?)".into())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let password = env::var(ENV_VAR)
        .unwrap_or_else(|_| DEFAULT_PASSWORD.to_string());
    
    if password.is_empty() {
        return Err(format!("{} is empty and no default password available", ENV_VAR).into());
    }

    let enc = general_purpose::STANDARD.decode(ENC_B64)?;
    let salt = general_purpose::STANDARD.decode(SALT_B64)?;
    let nonce = general_purpose::STANDARD.decode(NONCE_B64)?;

    let plain = decrypt(password.as_bytes(), &enc, &salt, &nonce)?;

    // インタープリターの絶対パスを取得
    let interp_path = which(INTERP[0])
        .map_err(|e| format!("Failed to find interpreter '{}': {}", INTERP[0], e))?;
    
    // インタープリターバイナリのSHA-256ハッシュを計算
    let binary_data = fs::read(&interp_path)
        .map_err(|e| format!("Failed to read binary '{}': {}", interp_path.display(), e))?;
    let mut interp_hasher = Sha256::new();
    interp_hasher.update(&binary_data);
    let interp_hash = interp_hasher.finalize();
    let interp_hash_hex = format!("{:x}", interp_hash);
    
    // スクリプト内容のSHA-256ハッシュを計算（期待値復号化用）
    let mut hasher = Sha256::new();
    hasher.update(&plain);
    let hash = hasher.finalize();
    let hash_hex = format!("{:x}", hash);
    
    // 期待値を復号化（バイナリハッシュをパスワードとして使用）
    let expected_path_enc = general_purpose::STANDARD.decode(EXPECTED_PATH_ENC_B64)?;
    let expected_path_plain = decrypt(hash_hex.as_bytes(), &expected_path_enc, &salt, &nonce)?;
    let expected_path = String::from_utf8(expected_path_plain)?;
    
    let expected_hash_enc = general_purpose::STANDARD.decode(EXPECTED_HASH_ENC_B64)?;
    let expected_hash_plain = decrypt(hash_hex.as_bytes(), &expected_hash_enc, &salt, &nonce)?;
    let expected_hash = String::from_utf8(expected_hash_plain)?;
    
    // 期待値と比較して検証
    if interp_path.to_string_lossy() != expected_path {
        return Err(format!(
            "Interpreter path mismatch!"
        ).into());
        //return Err(format!(
        //    "Interpreter path mismatch! Expected: {}, Found: {}", 
        //    expected_path, 
        //    interp_path.display()
        //).into());
    }
    
    if interp_hash_hex != expected_hash {
        return Err(format!(
            "Interpreter hash mismatch!",
        ).into());
        //return Err(format!(
        //    "Interpreter hash mismatch! Expected: {}, Found: {}", 
        //    expected_hash, 
        //    interp_hash_hex
        //).into());
    }

    let (read_fd, write_fd) = unsafe {
        let mut fds = [0; 2];
        if libc::pipe(fds.as_mut_ptr()) != 0 {
            return Err("pipe creation failed".into());
        }
        (fds[0], fds[1])
    };

    // write_fdにFD_CLOEXECフラグを設定して、子プロセスで自動的に閉じられるようにする
    unsafe {
        let flags = libc::fcntl(write_fd, libc::F_GETFD);
        libc::fcntl(write_fd, libc::F_SETFD, flags | libc::FD_CLOEXEC);
    }

    let mut args: Vec<String> = INTERP[1..].iter().map(|s| s.to_string()).collect();
    args.push(format!("/proc/self/fd/{}", read_fd));
    args.extend(env::args().skip(1));

    let mut cmd = Command::new(&interp_path)
        .args(&args)
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .spawn()?;

    unsafe { libc::close(read_fd); }

    let mut write_file = unsafe { std::fs::File::from_raw_fd(write_fd) };
    write_file.write_all(&plain)?;
    drop(write_file);

    let status = cmd.wait()?;
    if !status.success() {
        process::exit(status.code().unwrap_or(1));
    }

    Ok(())
}
"#;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(long, default_value = "RSEALPACK_PASS", help = "Env var name that holds password at build-time and runtime")]
    pass_env: String,
    
    #[arg(long, help = "Expected interpreter absolute path for verification")]
    expected_path: String,
    
    #[arg(long, help = "Expected interpreter SHA-256 hash for verification")]
    expected_hash: String,
    
    #[arg(long, default_value = "default_rsealpack_password", help = "Default password when env var is not set")]
    default_password: String,
    
    #[arg(long, help = "Interpreter command (e.g., 'perl', 'python', 'ruby')")]
    interpreter: String,
    
    #[arg(help = "Script file to encrypt")]
    script_file: String,
}


fn kdf(password: &[u8], salt: &[u8]) -> Result<[u8; 32], Box<dyn std::error::Error>> {
    let mut key = [0u8; 32];
    scrypt(password, salt, &scrypt::Params::new(15, 8, 1, 32)?, &mut key)?;
    Ok(key)
}

fn aes_gcm_encrypt(key: &[u8], nonce: &[u8], plaintext: &[u8]) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(key));
    let nonce = Nonce::<U12>::from_slice(nonce);
    
    cipher.encrypt(nonce, plaintext)
        .map_err(|_| "encryption failed".into())
}

fn rand_bytes(n: usize) -> Vec<u8> {
    let mut bytes = vec![0u8; n];
    OsRng.fill_bytes(&mut bytes);
    bytes
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();
    
    let password = env::var(&args.pass_env)
        .unwrap_or_else(|_| args.default_password.clone());
    
    if password.is_empty() {
        return Err(format!("{} is empty and no default password available", args.pass_env).into());
    }
    
    let plain = fs::read(&args.script_file)
        .map_err(|e| format!("read: {}", e))?;
    
    let interp = vec![args.interpreter.clone()];
    
    let salt = rand_bytes(16);
    let nonce = rand_bytes(12);
    let key = kdf(password.as_bytes(), &salt)?;
    let enc = aes_gcm_encrypt(&key, &nonce, &plain)?;
    
    let interp_list = interp.iter()
        .map(|s| format!("\"{}\"", s))
        .collect::<Vec<_>>()
        .join(", ");
    
    // スクリプト内容のハッシュを計算
    let mut hasher = Sha256::new();
    hasher.update(&plain);
    let hash = hasher.finalize();
    let hash_hex = format!("{:x}", hash);

    let expected_path = args.expected_path.clone();
    let expected_hash = args.expected_hash.clone();

    // 期待値の暗号化にはバイナリハッシュを使用
    let hash_key = kdf(hash_hex.as_bytes(), &salt)?;
    let expected_path_enc = aes_gcm_encrypt(&hash_key, &nonce, expected_path.as_bytes())?;
    let expected_hash_enc = aes_gcm_encrypt(&hash_key, &nonce, expected_hash.as_bytes())?;
    
    let rust_code = RUST_TEMPLATE
        .replace("{{ enc_b64 }}", &general_purpose::STANDARD.encode(&enc))
        .replace("{{ salt_b64 }}", &general_purpose::STANDARD.encode(&salt))
        .replace("{{ nonce_b64 }}", &general_purpose::STANDARD.encode(&nonce))
        .replace("{{ interp_list }}", &interp_list)
        .replace("{{ env_var }}", &args.pass_env)
        .replace("{{ default_password }}", &args.default_password)
        .replace("{{ expected_path_enc_b64 }}", &general_purpose::STANDARD.encode(&expected_path_enc))
        .replace("{{ expected_hash_enc_b64 }}", &general_purpose::STANDARD.encode(&expected_hash_enc));
    
    print!("{}", rust_code);
    
    Ok(())
}