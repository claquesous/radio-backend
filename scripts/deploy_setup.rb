#!/usr/bin/env ruby

require 'fileutils'
require 'time'
require 'open3'

DEPLOY_DIR = '/opt/claqradio/radio-backend/'
RELEASES_DIR = File.join(DEPLOY_DIR, 'releases')
CURRENT_SYMLINK = File.join(DEPLOY_DIR, 'current')
NEXT_SYMLINK = File.join(DEPLOY_DIR, 'next')
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

FileUtils.mkdir_p(new_release_dir)
puts "Created new release directory: #{new_release_dir}"

if File.exist?(NEXT_SYMLINK)
  FileUtils.rm(NEXT_SYMLINK)
end
FileUtils.ln_s(new_release_dir, NEXT_SYMLINK)
puts "Updated 'next' symlink to: #{new_release_dir}"

puts "Starting deployment process..."

# Backup current to previous
if File.exist?(PREVIOUS_SYMLINK)
  FileUtils.rm(PREVIOUS_SYMLINK)
  puts "Removed existing 'previous' symlink"
end

if File.exist?(CURRENT_SYMLINK)
  FileUtils.cp_r(CURRENT_SYMLINK, PREVIOUS_SYMLINK, preserve: true)
  puts "Created backup: current → previous"

  FileUtils.rm(CURRENT_SYMLINK)
  puts "Removed existing 'current' symlink"
end

# Set next as current
FileUtils.cp_r(NEXT_SYMLINK, CURRENT_SYMLINK, preserve: true)
puts "Deployed: next → current"

# Restart the service
puts "Restarting service..."
stdout, stderr, status = Open3.capture3("sudo systemctl restart claqradio-backend.service")

if status.success?
  puts "Service restarted successfully!"
else
  puts "Error restarting service:"
  puts stderr
end

puts "Deployment completed!"

