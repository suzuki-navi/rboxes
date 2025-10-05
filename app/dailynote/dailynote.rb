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
  
  # Calendar layout starting from Monday (1=Monday, 0=Sunday)
  # Find Monday of the week containing the first day
  days_from_monday = (first_day.wday == 0) ? 6 : first_day.wday - 1
  calendar_start = first_day - days_from_monday
  
  # Find Sunday of the week containing the last day
  days_to_sunday = (last_day.wday == 0) ? 0 : 7 - last_day.wday
  calendar_end = last_day + days_to_sunday
  
  # Generate calendar rows
  calendar_rows = []
  current_date = calendar_start
  
  while current_date <= calendar_end
    week_links = []
    7.times do
      week_links << "[[#{current_date.strftime('%Y%m%d')}]]"
      current_date += 1
    end
    calendar_rows << week_links.join(' ')
  end
  
  monthly_content = <<~CONTENT
. [[#{prev_month}]] - #{month_format} - [[#{next_month}]]

#{calendar_rows.join("\n")}
CONTENT
  
  File.write(monthly_file, monthly_content)
  puts "Created: #{monthly_file}"
end

puts "Done!"
