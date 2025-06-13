require 'rails_helper'

RSpec.describe "Requests", type: :request do
  let(:stream) { create(:stream) }
  let(:song) { create(:song) }
  let(:valid_params) { { request: { song_id: song.id } } }

  before do
    allow_any_instance_of(RequestsController).to receive(:authenticate_request)
  end

  describe "GET /streams/:stream_id/requests" do
    it "returns a successful response and requests in JSON" do
      request = create(:request, stream: stream, song: song)
      get stream_requests_path(stream), as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.map { |r| r["id"] }).to include(request.id)
    end

    it "returns an empty array if no requests" do
      get stream_requests_path(stream), as: :json
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end

  describe "POST /streams/:stream_id/requests" do
    context "with valid params" do
      it "responds with 201 and creates a request" do
        expect {
          post stream_requests_path(stream, format: :json), params: valid_params
        }.to change(Request, :count).by(1)
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["song_id"]).to eq(song.id)
      end
    end

    context "with invalid params" do
      it "returns 422 and error message" do
        post stream_requests_path(stream, format: :json), params: { request: { } }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("errors")
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        allow_any_instance_of(RequestsController).to receive(:authenticate_request).and_call_original
        post stream_requests_path(stream, format: :json), params: { request: { song_id: song.id } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
