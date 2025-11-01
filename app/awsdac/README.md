# awsdac

AWS Diagram as Code (awsdac) ツールのdockerized版です。AWS構成図をYAML記法で記述し、PNG画像として出力できます。

## 概要

このツールは[awslabs/diagram-as-code](https://github.com/awslabs/diagram-as-code)をDockerコンテナ内で実行するラッパーです。

## 使用方法

```bash
awsdac <入力ファイル> [フラグ]
```

### フラグ

- `-c, --cfn-template`: [beta] CloudFormationテンプレートから図を作成
- `-d, --dac-file`: [beta] CloudFormationテンプレートからdac (diagram-as-code) 形式のYAMLファイルを生成  
- `-h, --help`: ヘルプを表示
- `-o, --output string`: 出力ファイル名 (デフォルト: "output.png")
- `--override-def-file string`: テスト用にDefinitionFilesを別のURL/ローカルファイルで上書き
- `-t, --template`: 入力ファイルをtext/templateとして処理
- `-v, --verbose`: 詳細なログを有効化
- `--version`: バージョンを表示

## サンプル

`sample/alb-ec2.yaml`にALB + EC2の構成図のサンプルがあります。

```bash
# サンプル図を生成
awsdac sample/alb-ec2.yaml -o alb-diagram.png
```

## 要件

- Docker環境
- フォントファイル (コンテナ内にfonts-liberationがインストール済み)

フォントがないと以下のエラーが発生します：
```
panic: Specified fonts are not inllstalled.
```

## 出力

デフォルトでは`output.png`として現在のディレクトリに図が出力されます。`-o`オプションで出力先を指定できます。