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
end
