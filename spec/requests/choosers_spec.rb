require 'rails_helper'

RSpec.describe "/choosers", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:song) { create(:song) }
  let(:other_song) { create(:song) }

  describe "GET /streams/:stream_id/choosers" do
    context "as owner", :as_logged_in_user do
      before do
        @stream = create(:stream, user: @logged_in_user)
        @chooser = create(:chooser, stream: @stream, song: song)
      end

      it "returns choosers for the stream as the owner" do
        get stream_choosers_path(@stream)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(a_hash_including("id" => @chooser.id))
      end
    end
  end

  describe "POST /streams/:stream_id/choosers" do
    context "as owner", :as_logged_in_user do
      before { @stream = create(:stream, user: @logged_in_user) }

      it "creates a chooser as the owner" do
        song_id = other_song.id
        expect {
          post stream_choosers_path(@stream), params: { chooser: { song_id: song_id, rating: 42 } }
        }.to change { Chooser.count }.by(1)
        expect(response).to have_http_status(:created)
        expect(response.parsed_body["song"]["id"]).to eq(other_song.id)
      end

      it "returns error for missing song_id" do
        post stream_choosers_path(@stream), params: { chooser: { rating: 42 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "as non-owner" do
      before do
        @stream = create(:stream, user: user)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)
      end

      it "returns unauthorized for non-owner" do
        post stream_choosers_path(@stream), params: { chooser: { song_id: other_song.id, rating: 42 } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /streams/:stream_id/choosers/:id" do
    context "as owner", :as_logged_in_user do
      before do
        @stream = create(:stream, user: @logged_in_user)
        @chooser = create(:chooser, stream: @stream, song: song)
      end

      it "updates a chooser's rating as the owner" do
        patch stream_chooser_path(@stream, @chooser), params: { chooser: { rating: 99 } }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["rating"]).to eq(99)
      end

      it "returns not found for invalid id" do
        patch stream_chooser_path(@stream, 999999), params: { chooser: { rating: 88 } }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as non-owner" do
      before do
        @stream = create(:stream, user: user)
        @chooser = create(:chooser, stream: @stream, song: song)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)
      end

      it "returns unauthorized for non-owner" do
        patch stream_chooser_path(@stream, @chooser), params: { chooser: { rating: 88 } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /streams/:stream_id/choosers/:id" do
    context "as owner", :as_logged_in_user do
      before do
        @stream = create(:stream, user: @logged_in_user)
        @chooser = create(:chooser, stream: @stream, song: song)
      end

      it "deletes a chooser as the owner" do
        expect {
          delete stream_chooser_path(@stream, @chooser)
        }.to change { Chooser.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it "returns not found for invalid id" do
        delete stream_chooser_path(@stream, 999999)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as non-owner" do
      before do
        @stream = create(:stream, user: user)
        @chooser = create(:chooser, stream: @stream, song: song)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)
      end

      it "returns unauthorized for non-owner" do
        delete stream_chooser_path(@stream, @chooser)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "unauthorized requests" do
    let(:stream) { create(:stream) }
    let(:chooser) { create(:chooser, stream: stream, song: song) }

    it "returns unauthorized for index" do
      get stream_choosers_path(stream)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for create" do
      post stream_choosers_path(stream), params: { chooser: { song_id: other_song.id, rating: 42 } }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for update" do
      patch stream_chooser_path(stream, chooser), params: { chooser: { rating: 88 } }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for destroy" do
      delete stream_chooser_path(stream, chooser)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
