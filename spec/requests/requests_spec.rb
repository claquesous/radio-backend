require 'rails_helper'

RSpec.describe "Requests", type: :request do
  let(:stream) { create(:stream) }

  describe "GET /requests" do
    it "works! (now write some real specs)" do
      get stream_requests_path(stream)
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /requests" do
    it "responds with 302" do
      song = create(:song)
      post stream_requests_path(stream), params: { request: { song_id: song.id }}
      expect(response).to have_http_status(302)
    end

    it "responds with 201" do
      song = create(:song)
      post stream_requests_path(stream, format: :json), params: { request: { song_id: song.id }}
      expect(response).to have_http_status(201)
    end
  end
end
