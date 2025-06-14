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
    admin { false }

    after(:build) do |user|
      # Skip the set_initial_admin callback for test users
      user.define_singleton_method(:set_initial_admin) { }
    end

    factory :user_with_callback do
      admin { nil }

      after(:build) do |user|
        # Allow the original callback to run
        user.singleton_class.send(:remove_method, :set_initial_admin) if user.respond_to?(:set_initial_admin)
      end
    end
  end

  factory :stream do
    user
    name { "MyStream" }
    default_rating { 50.0 }
    default_featured { true }
    mastodon_url { "https://mastodon.social" }
    mastodon_access_token { "abcd1234" }
  end

  factory :chooser do
    stream
    song
    rating { 50 }
    featured { true }
  end

end

