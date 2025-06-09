#!/usr/bin/env ruby

require 'fileutils'
require 'time'

DEPLOY_DIR = '/opt/claqradio/radio-backend/'
RELEASES_DIR = File.join(DEPLOY_DIR, 'releases')
CURRENT_SYMLINK = File.join(DEPLOY_DIR, 'current')
NEXT_DIR = File.join(DEPLOY_DIR, 'next')
PREVIOUS_SYMLINK = File.join(DEPLOY_DIR, 'previous')
KEEP_RELEASES = 5

FileUtils.mkdir_p(RELEASES_DIR)

current_dir = File.expand_path(File.readlink(CURRENT_SYMLINK)) if File.exist?(CURRENT_SYMLINK)

dirs = Dir.entries(RELEASES_DIR).select do |entry|
  path = File.join(RELEASES_DIR, entry)
  File.directory?(path) && !(entry == '.' || entry == '..')
end.sort_by do |entry|
  File.mtime(File.join(RELEASES_DIR, entry))
end.reverse

keep_dirs = dirs.first(KEEP_RELEASES).map { |dir| File.join(RELEASES_DIR, dir) }
keep_dirs << current_dir if current_dir

dirs.each do |dir|
  full_path = File.join(RELEASES_DIR, dir)
  unless keep_dirs.include?(full_path)
    FileUtils.rm_rf(full_path)
    puts "Deleted directory: #{full_path}"
  end
end

puts "Cleanup complete. Retained the five most recent and the current directory."

timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
new_release_dir = File.join(RELEASES_DIR, timestamp)

# Move the extracted artifact directory into the new release directory
tmp_extract_dir = File.join(NEXT_DIR, "tmp")
if File.directory?(tmp_extract_dir)
  FileUtils.mv(tmp_extract_dir, new_release_dir)
  puts "Moved #{tmp_extract_dir} to #{new_release_dir}"
else
  puts "ERROR: Expected artifact extraction directory #{tmp_extract_dir} does not exist."
end

if File.exist?(CURRENT_SYMLINK)
  if File.exist?(PREVIOUS_SYMLINK)
    FileUtils.rm(PREVIOUS_SYMLINK)
  end
  FileUtils.ln_s(File.readlink(CURRENT_SYMLINK), PREVIOUS_SYMLINK)
  puts "Updated 'previous' symlink to: #{File.readlink(CURRENT_SYMLINK)}"
  FileUtils.rm(CURRENT_SYMLINK)
end

FileUtils.ln_s(new_release_dir, CURRENT_SYMLINK)
puts "Updated 'current' symlink to: #{new_release_dir}"

# Restart the backend service
puts "Restarting claqradio-backend.service..."
system("sudo systemctl restart claqradio-backend.service")
puts "Service restarted."
