class AddExternalIds < ActiveRecord::Migration[8.0]
  UUID_PATTERN = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"

  def up
    add_column :artists, :mb_artist_id, :uuid
    add_column :albums, :mb_release_group_id, :uuid
    add_column :albums, :discogs_master_id, :integer
    add_column :songs, :mb_recording_id, :uuid
    add_column :songs, :mb_work_ids, :uuid, array: true, default: [], null: false
    add_column :songs, :acoustid, :uuid
    add_column :songs, :discogs_release_id, :integer

    add_index :artists, :mb_artist_id
    add_index :albums, :mb_release_group_id
    add_index :songs, :mb_recording_id

    # Hand-picked matches from the admin MusicBrainz search are authoritative.
    { artists: :mb_artist_id, albums: :mb_release_group_id, songs: :mb_recording_id }.each do |table, column|
      execute <<~SQL
        UPDATE #{table} SET #{column} = (musicbrainz_metadata->>'id')::uuid
        WHERE musicbrainz_metadata->>'id' ~ '#{UUID_PATTERN}'
      SQL
    end
  end

  def down
    remove_column :artists, :mb_artist_id
    remove_column :albums, :mb_release_group_id
    remove_column :albums, :discogs_master_id
    remove_column :songs, :mb_recording_id
    remove_column :songs, :mb_work_ids
    remove_column :songs, :acoustid
    remove_column :songs, :discogs_release_id
  end
end
