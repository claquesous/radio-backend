require 'rails_helper'

RSpec.describe "Ratings", type: :request do
  describe "POST /ratings" do
    before :each do
      allow_any_instance_of(RatingsController).to receive(:authenticate_request)
    end

    it "responds with 201" do
      play = create(:play)
      post stream_ratings_path(play.stream, format: :json), params: { rating: { up: true, play_id: play.id }}
      expect(response).to have_http_status(201)
    end

    it "creates a new rating" do
      play = create(:play)
      expect {
        post stream_ratings_path(play.stream), params: { rating: { up: true, play_id: play.id }}
      }.to change(Rating, :count).by(1)
    end
  end
end
