require 'rails_helper'

RSpec.describe "similar songs and credits", type: :request do
  let(:seed) { create(:song_feature, sound: { 0 => 1.0 }, genre: { 0 => 1.0 }, release_year: 1990).song }
  let!(:match) { create(:song_feature, sound: { 0 => 1.0, 1 => 0.2 }, genre: { 1 => 1.0 }, release_year: 1991).song }

  describe "GET /songs/:id/similar" do
    it "returns ranked songs with per-facet scores" do
      get similar_song_url(seed), params: { sound: 1 }
      expect(response).to be_successful
      body = response.parsed_body
      expect(body["weights"]).to eq("sound" => "1")
      expect(body["results"].map { |r| r["id"] }).to eq([match.id])
      expect(body["results"].first["scores"].keys).to eq(["sound"])
      expect(body["results"].first["details"]).to include("sound", "genre", "era")
      expect(body["results"].first["artist"]["name"]).to eq(match.artist.name)
    end

    it "leaves out the seed's artist unless same_artist is given, and caps songs per artist" do
      own = create(:song_feature, sound: { 0 => 1.0, 1 => 0.1 }, song: create(:song, artist: seed.artist)).song
      also_own = create(:song_feature, sound: { 0 => 1.0, 1 => 0.15 }, song: create(:song, artist: seed.artist)).song

      get similar_song_url(seed), params: { sound: 1 }
      expect(response.parsed_body["results"].map { |r| r["id"] }).to eq([match.id])

      get similar_song_url(seed), params: { sound: 1, same_artist: 1 }
      expect(response.parsed_body["results"].map { |r| r["id"] }).to eq([own.id, match.id])

      get similar_song_url(seed), params: { sound: 1, same_artist: 1, per_artist: 2 }
      expect(response.parsed_body["results"].map { |r| r["id"] }).to eq([own.id, also_own.id, match.id])
    end

    it "uses default weights when none are given" do
      get similar_song_url(seed)
      expect(response.parsed_body["results"].first["scores"].keys).to contain_exactly("sound", "genre_era")
      expect(response.parsed_body["weights"]).to eq("sound" => 1.0, "creators" => 1.0, "genre_era" => 1.0)
    end
  end

  describe "GET /streams/:stream_id/songs/:id/similar" do
    it "only returns songs in the stream" do
      stream = create(:stream)
      get similar_stream_song_url(stream, seed), params: { sound: 1 }
      expect(response.parsed_body["results"]).to eq([])

      create(:chooser, stream:, song: match)
      get similar_stream_song_url(stream, seed), params: { sound: 1 }
      expect(response.parsed_body["results"].map { |r| r["id"] }).to eq([match.id])
    end
  end

  describe "POST /streams/:id/recommendations" do
    let!(:other) { create(:song_feature, sound: { 0 => 1.0, 1 => 0.4 }).song }

    it "seeds from the stream's own songs when no seed_ids are given", :as_logged_in_user do
      stream = create(:stream, user: @logged_in_user)
      create(:chooser, stream:, song: seed)
      post recommendations_stream_url(stream), params: { sound: 1 }, as: :json
      expect(response.parsed_body["seeds"]).to eq([{ "id" => seed.id, "title" => seed.title }])
      expect(response.parsed_body["results"].map { |r| r["id"] }).to eq([match.id, other.id])
    end

    it "recommends songs not yet in the stream, skipping excluded ids", :as_logged_in_user do
      stream = create(:stream, user: @logged_in_user)
      create(:chooser, stream:, song: seed)

      post recommendations_stream_url(stream), params: { seed_ids: [seed.id], sound: 1 }, as: :json
      expect(response).to be_successful
      expect(response.parsed_body["seeds"]).to eq([{ "id" => seed.id, "title" => seed.title }])
      expect(response.parsed_body["results"].map { |r| r["id"] }).to eq([match.id, other.id])

      create(:chooser, stream:, song: match)
      post recommendations_stream_url(stream), params: { seed_ids: [seed.id], sound: 1, exclude_ids: [other.id] }, as: :json
      expect(response.parsed_body["results"]).to eq([])
    end

    it "accepts an exclude list too long for a query string", :as_logged_in_user do
      stream = create(:stream, user: @logged_in_user)
      exclude_ids = (1_000_000..1_002_000).to_a + [match.id]
      post recommendations_stream_url(stream), params: { seed_ids: [seed.id], sound: 1, exclude_ids: }, as: :json
      expect(response.parsed_body["results"].map { |r| r["id"] }).to eq([other.id])
    end

    it "is only for the stream's owner", :as_logged_in_user do
      post recommendations_stream_url(create(:stream)), params: { seed_ids: [seed.id] }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /songs/:id/credits" do
    it "lists credits with people" do
      credit = create(:credit, song: seed, role: "lyricist")
      get credits_song_url(seed)
      expect(response.parsed_body).to eq([
        { "role" => "lyricist", "detail" => nil, "source" => "musicbrainz",
          "person" => { "id" => credit.person.id, "name" => credit.person.name, "mb_artist_id" => nil } }
      ])
    end
  end

  describe "GET /songs/:id" do
    it "includes analyzed features and tags" do
      seed.song_feature.update!(bpm: 128.0, key: 2, mode: "minor")
      create(:song_tag, song: seed, tag: "shoegaze")
      get song_url(seed)
      features = response.parsed_body["features"]
      expect(features).to include("bpm" => 128.0, "key" => 2, "mode" => "minor", "release_year" => 1990)
      expect(features["tags"]).to eq(["shoegaze"])
    end
  end
end
