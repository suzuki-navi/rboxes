#!/usr/bin/env ruby

require 'date'
require 'fileutils'
require 'optparse'

options = { force: false, directory: nil }
OptionParser.new do |opts|
  opts.banner = "Usage: dailynote <date> -d <directory>"
  opts.on('-d', '--directory DIR', 'Output directory path') do |dir|
    options[:directory] = dir
  end
  opts.on('-f', '--force', 'Allow overwriting existing files') do
    options[:force] = true
  end
end.parse!

if ARGV.length != 1 || options[:directory].nil?
  puts "Usage: dailynote <date> -d <directory>"
  puts "Example: dailynote 20250720 -d ~/work/inbox"
  exit 1
end

date_str = ARGV[0]
directory = File.expand_path(options[:directory])

unless date_str.match?(/^\d{8}$/)
  puts "Error: Date must be in YYYYMMDD format"
  exit 1
end

begin
  date = Date.strptime(date_str, '%Y%m%d')
rescue ArgumentError
  puts "Error: Invalid date #{date_str}"
  exit 1
end

# Ensure the target directory exists
FileUtils.mkdir_p(directory) unless File.directory?(directory)

daily_file = File.join(directory, "#{date_str}.md")
monthly_file = File.join(directory, "#{date.strftime('%Y%m')}.md")

if File.exist?(daily_file) && !options[:force]
  puts "Error: File #{daily_file} already exists (use -f to overwrite)"
  exit 1
end

prev_day = (date - 1).strftime('%Y%m%d')
next_day = (date + 1).strftime('%Y%m%d')

prev_week_day = (date - 7).strftime('%Y%m%d')
next_week_day = (date + 7).strftime('%Y%m%d')

weekday = %w[Sun Mon Tue Wed Thu Fri Sat][date.wday]

month_format = date.strftime('%Y%m')

daily_content = <<~CONTENT
---
tags:
  - daily
---
#{weekday}. [[#{prev_week_day}]] [[#{prev_day}]] - [[#{month_format}]] - [[#{next_day}]] [[#{next_week_day}]]

CONTENT

File.write(daily_file, daily_content)
puts "Created: #{daily_file}"

unless File.exist?(monthly_file)
  prev_month = (date << 1).strftime('%Y%m')
  next_month = (date >> 1).strftime('%Y%m')
  
  first_day = Date.new(date.year, date.month, 1)
  last_day = Date.new(date.year, date.month, -1)
  
  daily_links = []
  (first_day..last_day).each do |d|
    daily_links << "- [[#{d.strftime('%Y%m%d')}]]"
  end
  
  monthly_content = <<~CONTENT
. [[#{prev_month}]] - #{month_format} - [[#{next_month}]]

#{daily_links.join("\n")}
CONTENT
  
  File.write(monthly_file, monthly_content)
  puts "Created: #{monthly_file}"
end

puts "Done!"
