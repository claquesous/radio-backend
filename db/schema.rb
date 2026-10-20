# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_17_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "albums", id: :serial, force: :cascade do |t|
    t.integer "artist_id"
    t.string "title"
    t.string "sort"
    t.string "slug"
    t.integer "tracks"
    t.string "id3_genre"
    t.string "record_label"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "musicbrainz_metadata"
    t.uuid "mb_release_group_id"
    t.integer "discogs_master_id"
    t.index ["artist_id"], name: "index_albums_on_artist_id"
    t.index ["mb_release_group_id"], name: "index_albums_on_mb_release_group_id"
    t.index ["musicbrainz_metadata"], name: "index_albums_on_musicbrainz_metadata", using: :gin
  end

  create_table "artists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "sort"
    t.string "slug"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "musicbrainz_metadata"
    t.uuid "mb_artist_id"
    t.index ["mb_artist_id"], name: "index_artists_on_mb_artist_id"
    t.index ["musicbrainz_metadata"], name: "index_artists_on_musicbrainz_metadata", using: :gin
    t.index ["name"], name: "index_artists_on_name", unique: true
  end

  create_table "choosers", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.bigint "stream_id", null: false
    t.boolean "featured"
    t.float "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_choosers_on_song_id"
    t.index ["stream_id", "rating"], name: "index_choosers_on_stream_id_and_rating", where: "(featured = true)"
    t.index ["stream_id", "rating"], name: "index_choosers_on_stream_id_and_rating_unconditional"
    t.index ["stream_id"], name: "index_choosers_on_stream_id"
  end

  create_table "credits", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.bigint "person_id", null: false
    t.string "role", null: false
    t.string "detail"
    t.string "source", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id", "role"], name: "index_credits_on_person_id_and_role"
    t.index ["person_id"], name: "index_credits_on_person_id"
    t.index ["song_id", "person_id", "role", "source"], name: "index_credits_on_song_id_and_person_id_and_role_and_source", unique: true
    t.index ["song_id"], name: "index_credits_on_song_id"
  end

  create_table "facet_calibrations", force: :cascade do |t|
    t.string "facet", null: false
    t.float "p50", null: false
    t.float "p90", null: false
    t.float "p99", null: false
    t.float "p999", null: false
    t.integer "sample_pairs", null: false
    t.string "model_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facet"], name: "index_facet_calibrations_on_facet", unique: true
  end

  create_table "people", force: :cascade do |t|
    t.string "name", null: false
    t.uuid "mb_artist_id"
    t.integer "discogs_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discogs_id"], name: "index_people_on_discogs_id", unique: true, where: "(discogs_id IS NOT NULL)"
    t.index ["mb_artist_id"], name: "index_people_on_mb_artist_id", unique: true, where: "(mb_artist_id IS NOT NULL)"
    t.index ["name"], name: "index_people_on_name"
  end

  create_table "plays", id: :serial, force: :cascade do |t|
    t.integer "song_id"
    t.integer "ratings"
    t.datetime "playtime", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "tweet_id"
    t.bigint "stream_id"
    t.index ["song_id"], name: "index_plays_on_song_id"
    t.index ["stream_id"], name: "index_plays_on_stream_id"
  end

  create_table "ratings", id: :serial, force: :cascade do |t|
    t.integer "play_id", null: false
    t.boolean "up"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id", null: false
    t.index ["play_id"], name: "index_ratings_on_play_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "requests", id: :serial, force: :cascade do |t|
    t.integer "song_id"
    t.datetime "requested_at", precision: nil
    t.boolean "played"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "stream_id"
    t.bigint "user_id", null: false
    t.bigint "play_id"
    t.index ["play_id"], name: "index_requests_on_play_id"
    t.index ["song_id"], name: "index_requests_on_song_id"
    t.index ["stream_id"], name: "index_requests_on_stream_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "song_features", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.string "identify_status"
    t.datetime "identified_at"
    t.float "bpm"
    t.float "bpm_confidence"
    t.integer "key"
    t.string "mode"
    t.float "key_strength"
    t.float "loudness"
    t.float "danceability"
    t.jsonb "styles"
    t.vector "sound_embedding", limit: 1280
    t.string "sound_model_version"
    t.datetime "analyzed_at"
    t.integer "release_year"
    t.string "enrichment_status"
    t.datetime "enriched_at"
    t.string "creator_model_version"
    t.vector "genre_embedding", limit: 384
    t.string "genre_model_version"
    t.datetime "embedded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.sparsevec "creator_embedding", limit: 1000000
    t.index ["creator_embedding"], name: "index_song_features_on_creator_embedding", opclass: :sparsevec_cosine_ops, using: :hnsw
    t.index ["genre_embedding"], name: "index_song_features_on_genre_embedding", opclass: :vector_cosine_ops, using: :hnsw
    t.index ["release_year"], name: "index_song_features_on_release_year"
    t.index ["song_id"], name: "index_song_features_on_song_id", unique: true
    t.index ["sound_embedding"], name: "index_song_features_on_sound_embedding", opclass: :vector_cosine_ops, using: :hnsw
  end

  create_table "song_tags", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.string "tag", null: false
    t.float "weight", default: 1.0, null: false
    t.string "source", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id", "tag", "source"], name: "index_song_tags_on_song_id_and_tag_and_source", unique: true
    t.index ["song_id"], name: "index_song_tags_on_song_id"
    t.index ["tag"], name: "index_song_tags_on_tag"
  end

  create_table "songs", id: :serial, force: :cascade do |t|
    t.integer "album_id"
    t.integer "artist_id"
    t.string "title"
    t.string "sort"
    t.string "slug"
    t.integer "track"
    t.integer "time"
    t.boolean "featured"
    t.boolean "live"
    t.boolean "remix"
    t.float "rating"
    t.string "path"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "year"
    t.string "artist_name_override"
    t.jsonb "musicbrainz_metadata"
    t.uuid "mb_recording_id"
    t.uuid "mb_work_ids", default: [], null: false, array: true
    t.uuid "acoustid"
    t.integer "discogs_release_id"
    t.index ["album_id"], name: "index_songs_on_album_id"
    t.index ["artist_id", "title"], name: "index_songs_on_artist_id_and_title", unique: true
    t.index ["artist_id"], name: "index_songs_on_artist_id"
    t.index ["mb_recording_id"], name: "index_songs_on_mb_recording_id"
    t.index ["musicbrainz_metadata"], name: "index_songs_on_musicbrainz_metadata", using: :gin
    t.index ["rating", "featured"], name: "index_songs_on_rating_and_featured"
  end

  create_table "streams", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_mastodon_access_token"
    t.string "encrypted_mastodon_access_token_iv"
    t.string "mastodon_url"
    t.float "default_rating", default: 50.0, null: false
    t.boolean "default_featured", default: false, null: false
    t.boolean "premium", default: false, null: false
    t.string "genre"
    t.text "description"
    t.boolean "enabled", default: false, null: false
    t.index ["encrypted_mastodon_access_token_iv"], name: "index_streams_on_encrypted_mastodon_access_token_iv", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
  end

  add_foreign_key "albums", "artists"
  add_foreign_key "choosers", "songs"
  add_foreign_key "choosers", "streams"
  add_foreign_key "credits", "people"
  add_foreign_key "credits", "songs"
  add_foreign_key "plays", "songs"
  add_foreign_key "plays", "streams"
  add_foreign_key "ratings", "plays"
  add_foreign_key "ratings", "users"
  add_foreign_key "requests", "plays"
  add_foreign_key "requests", "songs"
  add_foreign_key "requests", "streams"
  add_foreign_key "requests", "users"
  add_foreign_key "song_features", "songs"
  add_foreign_key "song_tags", "songs"
  add_foreign_key "songs", "albums"
  add_foreign_key "songs", "artists"
end
