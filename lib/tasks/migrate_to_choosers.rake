# To be run immediately after db/migrate/20240527025859_create_choosers.rb
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
  end
end

