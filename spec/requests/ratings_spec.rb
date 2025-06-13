require 'rails_helper'

RSpec.describe "Ratings", type: :request do
  let(:play) { create(:play) }
  let(:stream) { play.stream }
  let(:valid_params) { { rating: { up: true, play_id: play.id } } }

  before do
    allow_any_instance_of(RatingsController).to receive(:authenticate_request)
  end

  describe "POST /ratings" do
    context "with valid params" do
      it "responds with 201" do
        post stream_ratings_path(stream, format: :json), params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "creates a new rating" do
        expect {
          post stream_ratings_path(stream, format: :json), params: valid_params
        }.to change(Rating, :count).by(1)
      end

      it "returns the created rating in JSON" do
        post stream_ratings_path(stream, format: :json), params: valid_params
        json = JSON.parse(response.body)
        expect(json["play_id"]).to eq(play.id)
        expect(json).to have_key("id")
      end
    end

    context "with invalid params" do
      it "returns 422 for missing play_id" do
        post stream_ratings_path(stream, format: :json), params: { rating: { up: true } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message for missing play_id" do
        post stream_ratings_path(stream, format: :json), params: { rating: { up: true } }
        json = JSON.parse(response.body)
        expect(json).to have_key("errors")
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        allow_any_instance_of(RatingsController).to receive(:authenticate_request).and_call_original
        post stream_ratings_path(stream, format: :json), params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "edge cases" do
      it "prevents duplicate ratings for the same play by the same user" do
        # Assuming there is a uniqueness validation on [user, play]
        user = create(:user)
        allow_any_instance_of(RatingsController).to receive(:current_user).and_return(user)
        post stream_ratings_path(stream, format: :json), params: valid_params
        post stream_ratings_path(stream, format: :json), params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
