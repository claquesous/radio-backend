require 'rails_helper'

RSpec.describe "Ratings", type: :request do
  let(:play) { create(:play) }
  let(:stream) { play.stream }
  let(:valid_params) { { rating: { up: true, play_id: play.id } } }

  describe "POST /ratings" do
    context "with valid params" do
      it "responds with 201", :as_logged_in_user do
        post stream_ratings_path(stream, format: :json), params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "creates a new rating", :as_logged_in_user do
        expect {
          post stream_ratings_path(stream, format: :json), params: valid_params
        }.to change(Rating, :count).by(1)
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        post stream_ratings_path(stream, format: :json), params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with duplicate ratings" do
      it "allows for the stream owner", :as_logged_in_user do
        stream.update(user: @logged_in_user)
        post stream_ratings_path(stream, format: :json), params: valid_params
        post stream_ratings_path(stream, format: :json), params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "prevents for non stream owner", :as_logged_in_user do
        post stream_ratings_path(stream, format: :json), params: valid_params
        post stream_ratings_path(stream, format: :json), params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
