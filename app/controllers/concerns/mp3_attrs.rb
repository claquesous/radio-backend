require 'mp3info'

module Mp3Attrs
  include SlugHelper

  def mp3_artist_name
    artist_name
  end

  def mp3_artist_sort
    artist_name.sub(/^The /, '')
  end

  def mp3_song_attrs
    attrs = {
      title: song_title,
      year: mp3_info.tag.year,
      time: mp3_info.length,
      path: SONGS_DIRECTORY + "/" + s3_path,
      sort: song_title.sub(/^The /, '')
    }
    attrs[:artist_name_override] = mp3_info.tag.artist if has_artist_override?
    attrs
  end

  private
  def s3_path
    "#{to_slug artist_name}/singles/#{to_slug song_title}"
  end

  def mp3_info
    @mp3_info ||= Mp3Info.new(uploaded_file.tempfile.path)
  end

  def has_artist_override?
    mp3_info.tag.artist =~ /\s+f\.\/.+/
  end

  def song_title
    mp3_info.tag.title
  end

  def artist_name
    mp3_info.tag.artist.sub(/\s+f\.\/.*/, '')
  end
end

