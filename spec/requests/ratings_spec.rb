require 'rails_helper'

RSpec.describe "Ratings", type: :request do
  describe "POST /ratings" do
    it "redirects" do
      play = create(:play)
      post stream_ratings_path(play.stream), params: { rating: { up: true, play_id: play.id }}
      expect(response).to have_http_status(302)
    end

    it "creates a new rating" do
      play = create(:play)
      expect {
        post stream_ratings_path(play.stream), params: { rating: { up: true, play_id: play.id }}
      }.to change(Rating, :count).by(1)
    end
  end
end
