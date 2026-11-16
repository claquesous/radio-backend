require 'rails_helper'

RSpec.describe "/plays", type: :request do
  let(:play) { create(:play) }
  let(:stream) { play.stream }

  describe "GET /streams/:stream_id/plays" do
    it "renders a successful response" do
      get stream_plays_url(stream), as: :json
      expect(response).to be_successful
    end

    it "returns plays in JSON" do
      get stream_plays_url(stream), as: :json
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.map { |p| p["id"] }).to include(play.id)
    end
  end

  describe "GET /streams/:stream_id/plays/:id" do
    it "renders a successful response" do
      get stream_play_url(stream, play), as: :json
      expect(response).to be_successful
    end

    it "returns play in JSON" do
      get stream_play_url(stream, play), as: :json
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(play.id)
    end
  end

  describe "GET /private/streams/:stream_id/plays/current" do
    let(:stream) { create(:stream) }

    def get_current
      get "/private/streams/#{stream.id}/plays/current", as: :json
    end

    it "returns the play on the air with its offset" do
      play = create(:play, stream: stream, playtime: 42.seconds.ago)

      get_current
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(play.id)
      expect(json["song"]["path"]).to eq(play.song.path)
      expect(json["offset"]).to be_within(1.0).of(42.0)
    end

    it "returns the latest play, not an older one" do
      create(:play, stream: stream, playtime: 5.minutes.ago)
      latest = create(:play, stream: stream, playtime: 10.seconds.ago)

      get_current
      expect(JSON.parse(response.body)["id"]).to eq(latest.id)
    end

    it "is 404 when the stream has never played anything" do
      get_current
      expect(response).to have_http_status(:not_found)
    end

    it "is 404 once the song has ended" do
      create(:play, stream: stream, playtime: 200.seconds.ago) # songs are 180s

      get_current
      expect(response).to have_http_status(:not_found)
    end

    it "is 404 when the song is about to end" do
      create(:play, stream: stream, playtime: 175.seconds.ago)

      get_current
      expect(response).to have_http_status(:not_found)
    end

    it "is 404 when the song's length is unknown" do
      create(:play, stream: stream, playtime: 10.seconds.ago, song: create(:song, time: nil))

      get_current
      expect(response).to have_http_status(:not_found)
    end

    it "does not record a play" do
      create(:play, stream: stream, playtime: 10.seconds.ago)

      expect { get_current }.not_to change(Play, :count)
    end
  end
end
