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
    title { "Song Title" } 
    sort { "Song Title" }
    slug { "song-title" }
    time { 180 }
    featured  { true }
    rating { 50 } 
    path { "/mnt/songs/artist/album/song" }
  end

  factory :play do
    song
  end

  factory :listener do
    twitter_handle { "TwitterHandle" }
  end

  factory :request do
    song
    listener
    twitter_handle { "TwitterHandle" }
  end

  factory :rating do
    play
    up { true }
    twitter_handle { "TwitterHandle" }
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@example.org" }
    password { "passw0rd" }
  end

  factory :stream do
    user
    name { "MyStream" }
  end

end

