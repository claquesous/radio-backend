require 'rails_helper'

RSpec.describe "Requests", type: :request do
  let(:stream) { create(:stream) }
  let(:song) { create(:song) }

  describe "GET /streams/:stream_id/requests" do
    it "returns a successful response and requests in JSON", :as_logged_in_user do
      request = create(:request, stream: stream, song: song)
      get stream_requests_path(stream), as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.map { |r| r["id"] }).to include(request.id)
    end

    it "returns an empty array if no requests", :as_logged_in_user do
      get stream_requests_path(stream), as: :json
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end

  describe "POST /streams/:stream_id/requests" do
    context "when authenticated" do
      it "returns 201", :as_logged_in_user do
        post stream_requests_path(stream, format: :json), params: { request: { song_id: song.id } }
        expect(response).to have_http_status(:created)
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        post stream_requests_path(stream, format: :json), params: { request: { song_id: song.id } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
