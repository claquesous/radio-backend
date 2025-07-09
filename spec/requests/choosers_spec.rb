require 'rails_helper'

RSpec.describe "Choosers", type: :request do
  let(:other_user) { create(:user) }
  let(:stream) { create(:stream, user: @logged_in_user) }
  let(:song) { create(:song) }
  let(:other_song) { create(:song) }
  let(:chooser) { create(:chooser, stream: stream, song: song) }

  describe "GET /streams/:stream_id/choosers", :as_logged_in_user do
    it "returns choosers for the stream as the owner" do
      chooser
      get stream_choosers_path(stream.id)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(a_hash_including("id" => chooser.id))
    end

    it "returns forbidden for non-owner" do
      stream = create(:stream, user: other_user)
      chooser
      get stream_choosers_path(stream.id)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /streams/:stream_id/choosers/:id", :as_logged_in_user do
    it "shows a chooser as the owner" do
      get stream_chooser_path(stream.id, chooser.id)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["id"]).to eq(chooser.id)
    end

    it "returns not found for invalid id" do
      get stream_chooser_path(stream.id, 999999)
      expect(response).to have_http_status(:not_found)
    end

    it "returns forbidden for non-owner" do
      stream = create(:stream, user: other_user)
      get stream_chooser_path(stream.id, chooser.id)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /streams/:stream_id/choosers", :as_logged_in_user do
    it "creates a chooser as the owner" do
      expect {
        post stream_choosers_path(stream.id), params: { chooser: { song_id: other_song.id, rating: 42 } }
      }.to change { Chooser.count }.by(1)
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["song"]["id"]).to eq(other_song.id)
    end

    it "returns error for duplicate chooser" do
      chooser
      post stream_choosers_path(stream.id), params: { chooser: { song_id: song.id, rating: 42 } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns error for missing song_id" do
      post stream_choosers_path(stream.id), params: { chooser: { rating: 42 } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns forbidden for non-owner" do
      stream = create(:stream, user: other_user)
      post stream_choosers_path(stream.id), params: { chooser: { song_id: other_song.id, rating: 42 } }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /streams/:stream_id/choosers/:id", :as_logged_in_user do
    it "updates a chooser's rating as the owner" do
      patch stream_chooser_path(stream.id, chooser.id), params: { chooser: { rating: 99 } }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["rating"]).to eq(99)
    end

    it "returns error for invalid params" do
      patch stream_chooser_path(stream.id, chooser.id), params: { chooser: { rating: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns forbidden for non-owner" do
      stream = create(:stream, user: other_user)
      patch stream_chooser_path(stream.id, chooser.id), params: { chooser: { rating: 88 } }
      expect(response).to have_http_status(:forbidden)
    end

    it "returns not found for invalid id" do
      patch stream_chooser_path(stream.id, 999999), params: { chooser: { rating: 88 } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /streams/:stream_id/choosers/:id", :as_logged_in_user do
    it "deletes a chooser as the owner" do
      chooser # create it
      expect {
        delete stream_chooser_path(stream.id, chooser.id)
      }.to change { Chooser.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "returns forbidden for non-owner" do
      stream = create(:stream, user: other_user)
      chooser
      delete stream_chooser_path(stream.id, chooser.id)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns not found for invalid id" do
      delete stream_chooser_path(stream.id, 999999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "unauthorized requests" do
    it "returns unauthorized for index" do
      get stream_choosers_path(stream.id)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for show" do
      get stream_chooser_path(stream.id, chooser.id)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for create" do
      post stream_choosers_path(stream.id), params: { chooser: { song_id: other_song.id, rating: 42 } }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for update" do
      patch stream_chooser_path(stream.id, chooser.id), params: { chooser: { rating: 88 } }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for destroy" do
      delete stream_chooser_path(stream.id, chooser.id)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
