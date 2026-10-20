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
    default_featured { false }
    mastodon_url { "https://mastodon.social" }
    mastodon_access_token { "abcd1234" }
  end

  factory :chooser do
    stream
    song
    rating { 50 }
  end

  factory :song_feature do
    song
    transient do
      sound { nil }    # e.g. { 0 => 1.0, 1 => 0.2 }, see SpecVectors.vec
      creators { nil }  # e.g. { 7 => 1.0 }: person id => weight
      genre { nil }
    end
    sound_embedding { sound && SpecVectors.vec(1280, sound) }
    creator_embedding { creators && SpecVectors.sparse(creators) }
    genre_embedding { genre && SpecVectors.vec(384, genre) }
  end

  factory :facet_calibration do
    facet { "sound" }
    p50 { 0.0 }
    p90 { 0.5 }
    p99 { 0.9 }
    p999 { 1.0 }
    sample_pairs { 100 }
  end

  factory :person do
    sequence(:name) { |n| "Person #{n}" }
  end

  factory :credit do
    song
    person
    role { "producer" }
    source { "musicbrainz" }
  end

  factory :song_tag do
    song
    tag { "post-punk" }
    weight { 1.0 }
    source { "musicbrainz" }
  end

end
