# To be run immediately after db/migrate/20240527025859_create_choosers.rb
# db/migrate/20240527181932_add_stream_to_plays.rb
# db/migrate/20240527181944_add_stream_to_requests.rb
namespace :db do
  desc "Migrate data from songs to choosers"
  task migrate_to_choosers: :environment do
    Song.find_each do |song|
      Chooser.create!(
        song_id: song.id,
        stream_id: 1, # Assuming the single stream with id 1
        featured: song.featured,
        rating: song.rating
      )
    end
    Request.update_all(stream_id: 1)
    Play.update_all(stream_id: 1)
  end
end

