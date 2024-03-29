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

ActiveRecord::Schema[7.1].define(version: 2024_02_15_172751) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["artist_id"], name: "index_albums_on_artist_id"
  end

  create_table "artists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "sort"
    t.string "slug"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_artists_on_name", unique: true
  end

  create_table "listeners", id: :serial, force: :cascade do |t|
    t.string "twitter_handle"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["twitter_handle"], name: "index_listeners_on_twitter_handle"
  end

  create_table "plays", id: :serial, force: :cascade do |t|
    t.integer "song_id"
    t.integer "ratings"
    t.datetime "playtime", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "tweet_id"
    t.index ["song_id"], name: "index_plays_on_song_id"
  end

  create_table "ratings", id: :serial, force: :cascade do |t|
    t.integer "play_id"
    t.boolean "up"
    t.string "twitter_handle"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "listener_id"
    t.index ["listener_id"], name: "index_ratings_on_listener_id"
    t.index ["play_id"], name: "index_ratings_on_play_id"
  end

  create_table "requests", id: :serial, force: :cascade do |t|
    t.string "twitter_handle"
    t.integer "song_id"
    t.datetime "requested_at", precision: nil
    t.boolean "played"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "listener_id"
    t.index ["listener_id"], name: "index_requests_on_listener_id"
    t.index ["song_id"], name: "index_requests_on_song_id"
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
    t.index ["album_id"], name: "index_songs_on_album_id"
    t.index ["artist_id"], name: "index_songs_on_artist_id"
    t.index ["rating", "featured"], name: "index_songs_on_rating_and_featured"
  end

  add_foreign_key "albums", "artists"
  add_foreign_key "plays", "songs"
  add_foreign_key "ratings", "listeners"
  add_foreign_key "ratings", "plays"
  add_foreign_key "requests", "listeners"
  add_foreign_key "requests", "songs"
  add_foreign_key "songs", "albums"
  add_foreign_key "songs", "artists"
end
