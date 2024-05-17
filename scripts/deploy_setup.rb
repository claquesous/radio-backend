#!/usr/bin/env ruby

require 'fileutils'
require 'time'

DEPLOY_DIR = '/opt/claqradio/radio-backend/'
RELEASES_DIR = File.join(DEPLOY_DIR, 'releases')
CURRENT_SYMLINK = File.join(DEPLOY_DIR, 'current')
KEEP_RELEASES = 5

current_dir = File.expand_path(File.readlink(CURRENT_SYMLINK))

dirs = Dir.entries(RELEASES_DIR).select do |entry|
  path = File.join(RELEASES_DIR, entry)
  File.directory?(path) && !(entry == '.' || entry == '..')
end.sort_by do |entry|
  File.mtime(File.join(RELEASES_DIR, entry))
end.reverse

keep_dirs = dirs.first(KEEP_RELEASES).map { |dir| File.join(RELEASES_DIR, dir) }
keep_dirs << current_dir

keep_dirs_set = keep_dirs.to_set

dirs.each do |dir|
  full_path = File.join(RELEASES_DIR, dir)
  unless keep_dirs_set.include?(full_path)
    FileUtils.rm_rf(full_path)
    puts "Deleted directory: #{full_path}"
  end
end

puts "Cleanup complete. Retained the five most recent and the current directory."

timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
new_release_dir = File.join(RELEASES_DIR, timestamp)

FileUtils.mkdir_p(RELEASES_DIR)
FileUtils.mkdir_p(new_release_dir)
puts "Created new release directory: #{new_release_dir}"

if File.exist?(CURRENT_SYMLINK)
  FileUtils.rm(CURRENT_SYMLINK)
end
FileUtils.ln_s(new_release_dir, CURRENT_SYMLINK)
puts "Updated 'current' symlink to: #{new_release_dir}"

