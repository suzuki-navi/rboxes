#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'optparse'
require 'unicode/display_width'

#-------------------------
# ユーティリティ関数
#-------------------------

# UTF-8文字の表示幅を取得（East Asian Width対応）
def get_char_width(char)
  return 1 if char == '.'
  Unicode::DisplayWidth.of(char) || 1
end

# UTF-8文字境界を見つける（指定バイト数以降の最初の境界）
def find_utf8_boundary_after(data, min_pos)
  return data.size if min_pos >= data.size
  
  pos = min_pos
  while pos < data.size
    byte = data.getbyte(pos)
    # ASCII文字またはUTF-8マルチバイト文字の先頭バイト
    if byte < 0x80 || (byte & 0b11000000) == 0b11000000
      return pos
    end
    pos += 1
  end
  
  data.size
end

# バイトデータをUTF-8文字列にデコード（不正な文字は'.'に置換）
def decode_to_utf8_safe(data)
  result = ""
  i = 0
  
  while i < data.size
    byte = data.getbyte(i)
    
    if byte < 0x80
      # ASCII文字
      char = byte.chr('UTF-8')
      result += char.match?(/[[:print:]]/) && !char.match?(/[[:cntrl:]]/) ? char : '.'
      i += 1
    else
      # マルチバイト文字の処理
      char_len = get_utf8_char_length(byte)
      if i + char_len <= data.size
        begin
          char_bytes = data[i, char_len]
          char = char_bytes.force_encoding('UTF-8')
          if char.valid_encoding?
            result += char.match?(/[[:print:]]/) && !char.match?(/[[:cntrl:]]/) ? char : '.'
          else
            result += '.'
          end
        rescue
          result += '.'
        end
        i += char_len
      else
        # 不完全な文字
        result += '.'
        i += 1
      end
    end
  end
  
  result
end

# UTF-8文字の先頭バイトから文字長を取得
def get_utf8_char_length(first_byte)
  if (first_byte & 0b11100000) == 0b11000000
    2
  elsif (first_byte & 0b11110000) == 0b11100000
    3
  elsif (first_byte & 0b11111000) == 0b11110000
    4
  else
    1 # 不正なバイトは1バイトとして扱う
  end
end

# UTF-8文字をHEXバイト位置に合わせて配置
def align_utf8_with_hex(utf8_text, raw_data)
  result = ""
  hex_pos = 0
  utf8_chars = utf8_text.chars
  char_index = 0
  
  (0...raw_data.size).each do |byte_pos|
    # HEX表示での位置を計算
    target_pos = byte_pos * 3  # "XX "
    target_pos += 1 if byte_pos == 8  # 8バイト目の後の追加スペース
    
    # 現在位置を目標位置まで進める
    while hex_pos < target_pos
      result += ' '
      hex_pos += 1
    end
    
    # この位置にUTF-8文字があるかチェック
    if char_index < utf8_chars.size
      char = utf8_chars[char_index]
      char_byte_size = char.bytesize
      
      # この文字がこのバイト位置から始まるかチェック
      if byte_pos == get_char_start_position(utf8_text, char_index)
        result += char
        char_width = get_char_width(char)
        hex_pos += char_width
        char_index += 1
      end
    end
  end
  
  result
end

# 指定されたUTF-8文字のバイト開始位置を取得
def get_char_start_position(utf8_text, char_index)
  byte_pos = 0
  utf8_text.chars[0...char_index].each do |char|
    byte_pos += char.bytesize
  end
  byte_pos
end

#-------------------------
# メイン処理
#-------------------------

# オプション解析
options = { width: 16, no_break_on_newline: false }
OptionParser.new do |opts|
  opts.banner = "Usage: hexdumpch [options] [file]"
  opts.on('-w', '--width WIDTH', Integer, 'Number of bytes per line (default: 16)') do |w|
    options[:width] = w
  end
  opts.on('-n', '--no-break-on-newline', 'Do not break lines on newline (0x0a) characters') do
    options[:no_break_on_newline] = true
  end
  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit
  end
end.parse!

width = options[:width]
no_break_on_newline = options[:no_break_on_newline]

# 入力ソース
input = ARGV.empty? ? STDIN : File.open(ARGV[0], 'rb')

begin
  offset = 0
  leftover_data = ""
  is_line_start = true
  line_number = 1
  
  while true
    # データ読み込み
    if leftover_data.empty?
      new_data = input.read(width * 2)  # 余裕を持って読み込み
      break if new_data.nil? || new_data.empty?
      data = new_data
    else
      remaining = width * 2 - leftover_data.size
      new_data = remaining > 0 ? input.read(remaining) : ""
      data = leftover_data + (new_data || "")
      leftover_data = ""
    end
    
    break if data.empty?
    
    # 改行文字での分割処理
    was_broken_by_newline = false
    unless no_break_on_newline
      newline_pos = data.index("\n")
      if newline_pos
        leftover_data = data[newline_pos + 1..-1] || ""
        data = data[0..newline_pos]
        was_broken_by_newline = true
      end
    end
    
    # UTF-8文字境界での分割（16バイト以降の最初の境界）
    if no_break_on_newline
      if data.size > width
        leftover_data = data[width..-1] + leftover_data
        data = data[0, width]
      end
    else
      if data.size > width #&& !was_broken_by_newline
        split_pos = find_utf8_boundary_after(data, width)
        if split_pos > width && split_pos < data.size
          leftover_data = data[split_pos..-1] + leftover_data
          data = data[0, split_pos]
        elsif data.size > width
          # 境界が見つからない場合は16バイトで切る
          leftover_data = data[width..-1] + leftover_data
          data = data[0, width]
        end
      end
    end
    
    # HEX行の生成
    hex_line = ""
    (0...data.size).each do |i|
      if i < data.size
        hex_line += sprintf('%02x ', data.getbyte(i))
      else
        hex_line += '   '
      end
    end
    
    # 行頭マーカーと行番号
    if no_break_on_newline
      marker = '  '
      line_prefix = ""
    else
      if is_line_start
        marker = '> '
        line_prefix = sprintf("%4d:", line_number)
      else
        marker = '  '
        line_prefix = "     "
      end
    end
    
    # HEX行出力
    printf "%s%s%06x  %s\n", line_prefix, marker, offset, hex_line
    
    # UTF-8行の生成と出力
    utf8_text = decode_to_utf8_safe(data)
    aligned_utf8 = align_utf8_with_hex(utf8_text, data)
    utf8_indent = no_break_on_newline ? "          " : "               "
    printf "%s%s\n", utf8_indent, aligned_utf8
    
    # 次の行の状態更新
    was_line_start = is_line_start
    is_line_start = data[-1] == "\n"
    if is_line_start
      line_number += 1
    end
    offset += data.size
  end
  
ensure
  input.close if input != STDIN
end