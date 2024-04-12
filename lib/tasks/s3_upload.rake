require 'aws-sdk-s3'

namespace :radio do
  def to_slug(value)
    value.downcase.gsub(/[^a-z0-9]+/, '-').chomp('-')
  end

  desc "Uploads locally hosted files to an s3 bucket"
  task s3_upload: :environment do
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])

    bucket_name = ENV['AWS_S3_BUCKET']

    Song.all.each do |s|
      s3_name = "#{to_slug s.artist.name}/#{to_slug s.album.try(:title) || 'singles'}/#{to_slug s.title}"

      obj = s3.bucket(bucket_name).object(s3_name)
      obj.upload_file(s.path)
      puts "#{s.path} => #{s3_name}"
    end
  end

end

