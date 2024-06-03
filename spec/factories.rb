FactoryBot.define do

  factory :artist do
    sequence(:name) { |n| "Artist Name #{n}" }
    sort { "Artist Name" }
    slug { "artist-name" }
  end

  factory :album do
    artist
    title { "Album Title" }
    sort  { "Album Title" }
    slug  { "album-title" }
  end

  factory :song do
    album
    artist
    sequence(:title) { |n| "Song Title #{n}" }
    sort { "Song Title" }
    slug { "song-title" }
    time { 180 }
    featured  { true }
    rating { 50 } 
    path { "/mnt/songs/artist/album/song" }
  end

  factory :play do
    stream
    song
  end

  factory :request do
    stream
    song
    user
    requested_at { 2.hours.ago }
    played { false }
  end

  factory :rating do
    play
    up { true }
    user
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@example.org" }
    password { "passw0rd" }
  end

  factory :stream do
    user
    name { "MyStream" }
  end

  factory :chooser do
    stream
    song
    rating { 50 }
    featured { true }
  end

end

