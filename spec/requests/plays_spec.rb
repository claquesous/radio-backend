require 'rails_helper'

RSpec.describe "/plays", type: :request do
  let(:play) { create(:play) }
  let(:stream) { play.stream }

  before do
    allow_any_instance_of(PlaysController).to receive(:authenticate_request)
  end

  describe "GET /streams/:stream_id/plays" do
    context "when authenticated" do
      it "renders a successful response and returns plays in JSON" do
        get stream_plays_url(stream), as: :json
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json.map { |p| p["id"] }).to include(play.id)
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        allow_any_instance_of(PlaysController).to receive(:authenticate_request).and_call_original
        get stream_plays_url(stream), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /streams/:stream_id/plays/:id" do
    context "when authenticated" do
      it "renders a successful response and returns play in JSON" do
        get stream_play_url(stream, play), as: :json
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(play.id)
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        allow_any_instance_of(PlaysController).to receive(:authenticate_request).and_call_original
        get stream_play_url(stream, play), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
