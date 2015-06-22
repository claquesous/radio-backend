# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150622010401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.integer  "artist_id"
    t.string   "title"
    t.string   "sort"
    t.string   "slug"
    t.integer  "tracks"
    t.string   "id3_genre"
    t.string   "record_label"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "albums", ["artist_id"], name: "index_albums_on_artist_id", using: :btree

  create_table "artists", force: :cascade do |t|
    t.string   "name"
    t.string   "sort"
    t.string   "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "artists", ["name"], name: "index_artists_on_name", unique: true, using: :btree

  create_table "listeners", force: :cascade do |t|
    t.string   "twitter_handle"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "listeners", ["twitter_handle"], name: "index_listeners_on_twitter_handle", using: :btree

  create_table "plays", force: :cascade do |t|
    t.integer  "song_id"
    t.integer  "ratings"
    t.datetime "playtime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "tweet_id"
  end

  add_index "plays", ["song_id"], name: "index_plays_on_song_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "play_id"
    t.boolean  "up"
    t.string   "twitter_handle"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "listener_id"
  end

  add_index "ratings", ["listener_id"], name: "index_ratings_on_listener_id", using: :btree
  add_index "ratings", ["play_id"], name: "index_ratings_on_play_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.string   "twitter_handle"
    t.integer  "song_id"
    t.datetime "requested_at"
    t.boolean  "played"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "listener_id"
  end

  add_index "requests", ["listener_id"], name: "index_requests_on_listener_id", using: :btree
  add_index "requests", ["song_id"], name: "index_requests_on_song_id", using: :btree

  create_table "songs", force: :cascade do |t|
    t.integer  "album_id"
    t.integer  "artist_id"
    t.string   "title"
    t.string   "sort"
    t.string   "slug"
    t.integer  "track"
    t.integer  "time"
    t.boolean  "featured"
    t.boolean  "live"
    t.boolean  "remix"
    t.float    "rating"
    t.string   "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "songs", ["album_id"], name: "index_songs_on_album_id", using: :btree
  add_index "songs", ["artist_id"], name: "index_songs_on_artist_id", using: :btree
  add_index "songs", ["rating", "featured"], name: "index_songs_on_rating_and_featured", using: :btree

  add_foreign_key "albums", "artists"
  add_foreign_key "plays", "songs"
  add_foreign_key "ratings", "listeners"
  add_foreign_key "ratings", "plays"
  add_foreign_key "requests", "listeners"
  add_foreign_key "requests", "songs"
  add_foreign_key "songs", "albums"
  add_foreign_key "songs", "artists"
end
