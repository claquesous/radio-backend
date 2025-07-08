require 'rails_helper'

RSpec.describe "Choosers API", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:stream) { create(:stream, user: user) }
  let(:song) { create(:song) }
  let(:other_song) { create(:song) }
  let(:chooser) { create(:chooser, stream: stream, song: song) }

  describe "GET /streams/:stream_id/choosers" do
    it "returns choosers for the stream as the owner" do
      chooser
      as_logged_in_user(user) do
        get "/streams/#{stream.id}/choosers"
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(a_hash_including("id" => chooser.id))
      end
    end

    it "returns forbidden for non-owner" do
      chooser
      as_logged_in_user(other_user) do
        get "/streams/#{stream.id}/choosers"
        expect(response).to have_http_status(:forbidden)
      end
    end

    it "returns unauthorized if not logged in" do
      get "/streams/#{stream.id}/choosers"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /streams/:stream_id/choosers/:id" do
    it "shows a chooser as the owner" do
      as_logged_in_user(user) do
        get "/streams/#{stream.id}/choosers/#{chooser.id}"
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["id"]).to eq(chooser.id)
      end
    end

    it "returns not found for invalid id" do
      as_logged_in_user(user) do
        get "/streams/#{stream.id}/choosers/999999"
        expect(response).to have_http_status(:not_found)
      end
    end

    it "returns forbidden for non-owner" do
      as_logged_in_user(other_user) do
        get "/streams/#{stream.id}/choosers/#{chooser.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end

    it "returns unauthorized if not logged in" do
      get "/streams/#{stream.id}/choosers/#{chooser.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /streams/:stream_id/choosers" do
    it "creates a chooser as the owner" do
      as_logged_in_user(user) do
        expect {
          post "/streams/#{stream.id}/choosers", params: { chooser: { song_id: other_song.id, rating: 42 } }
        }.to change { Chooser.count }.by(1)
        expect(response).to have_http_status(:created)
        expect(response.parsed_body["song"]["id"]).to eq(other_song.id)
      end
    end

    it "returns error for duplicate chooser" do
      chooser
      as_logged_in_user(user) do
        post "/streams/#{stream.id}/choosers", params: { chooser: { song_id: song.id, rating: 42 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns error for missing song_id" do
      as_logged_in_user(user) do
        post "/streams/#{stream.id}/choosers", params: { chooser: { rating: 42 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns forbidden for non-owner" do
      as_logged_in_user(other_user) do
        post "/streams/#{stream.id}/choosers", params: { chooser: { song_id: other_song.id, rating: 42 } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    it "returns unauthorized if not logged in" do
      post "/streams/#{stream.id}/choosers", params: { chooser: { song_id: other_song.id, rating: 42 } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /streams/:stream_id/choosers/:id" do
    it "updates a chooser's rating as the owner" do
      as_logged_in_user(user) do
        patch "/streams/#{stream.id}/choosers/#{chooser.id}", params: { chooser: { rating: 99 } }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["rating"]).to eq(99)
      end
    end

    it "returns error for invalid params" do
      as_logged_in_user(user) do
        patch "/streams/#{stream.id}/choosers/#{chooser.id}", params: { chooser: { rating: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns forbidden for non-owner" do
      as_logged_in_user(other_user) do
        patch "/streams/#{stream.id}/choosers/#{chooser.id}", params: { chooser: { rating: 88 } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    it "returns not found for invalid id" do
      as_logged_in_user(user) do
        patch "/streams/#{stream.id}/choosers/999999", params: { chooser: { rating: 88 } }
        expect(response).to have_http_status(:not_found)
      end
    end

    it "returns unauthorized if not logged in" do
      patch "/streams/#{stream.id}/choosers/#{chooser.id}", params: { chooser: { rating: 88 } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /streams/:stream_id/choosers/:id" do
    it "deletes a chooser as the owner" do
      chooser # create it
      as_logged_in_user(user) do
        expect {
          delete "/streams/#{stream.id}/choosers/#{chooser.id}"
        }.to change { Chooser.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    it "returns forbidden for non-owner" do
      chooser
      as_logged_in_user(other_user) do
        delete "/streams/#{stream.id}/choosers/#{chooser.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end

    it "returns not found for invalid id" do
      as_logged_in_user(user) do
        delete "/streams/#{stream.id}/choosers/999999"
        expect(response).to have_http_status(:not_found)
      end
    end

    it "returns unauthorized if not logged in" do
      delete "/streams/#{stream.id}/choosers/#{chooser.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
