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

timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
new_release_dir = File.join(RELEASES_DIR, timestamp)

# Move 'next' (artifact extraction) to new release directory
puts "Moving 'next' to #{new_release_dir}"
FileUtils.mv(NEXT_DIR, new_release_dir)

puts "Starting deployment process..."

# Backup current to previous
if File.exist?(PREVIOUS_SYMLINK)
  FileUtils.rm(PREVIOUS_SYMLINK)
  puts "Removed existing 'previous' symlink"
end

if File.exist?(CURRENT_SYMLINK)
  current_target = File.readlink(CURRENT_SYMLINK)
  FileUtils.ln_s(current_target, PREVIOUS_SYMLINK)
  puts "Created backup symlink: previous → #{current_target}"
  
  FileUtils.rm(CURRENT_SYMLINK)
  puts "Removed existing 'current' symlink"
end

# Set current to new release
FileUtils.ln_s(new_release_dir, CURRENT_SYMLINK)
puts "Created deployment symlink: current → #{new_release_dir}"

puts "Deployment completed!"

puts "Running final cleanup..."
# Get all release directories again after deployment
all_dirs = Dir.entries(RELEASES_DIR).select do |entry|
  path = File.join(RELEASES_DIR, entry)
  File.directory?(path) && !(entry == '.' || entry == '..')
end.sort_by do |entry|
  File.mtime(File.join(RELEASES_DIR, entry))
end.reverse

# Identify symlink targets that must be preserved
current_target = File.readlink(CURRENT_SYMLINK) if File.exist?(CURRENT_SYMLINK)
previous_target = File.readlink(PREVIOUS_SYMLINK) if File.exist?(PREVIOUS_SYMLINK)

# Create array of directories to keep
keep_dirs = []
keep_dirs << current_target if current_target
keep_dirs << previous_target if previous_target

# Add additional recent directories up to KEEP_RELEASES total
all_dirs.each do |dir|
  full_path = File.join(RELEASES_DIR, dir)
  # Skip if already in keep_dirs
  next if keep_dirs.include?(full_path)
  
  # Add to keep_dirs if we haven't reached the limit
  if keep_dirs.size < KEEP_RELEASES
    keep_dirs << full_path
  end
end

# Delete everything not in keep_dirs
all_dirs.each do |dir|
  full_path = File.join(RELEASES_DIR, dir)
  unless keep_dirs.include?(full_path)
    FileUtils.rm_rf(full_path)
    puts "Deleted old release: #{full_path}"
  end
end

puts "Final cleanup complete. Kept exactly #{keep_dirs.size} releases."
