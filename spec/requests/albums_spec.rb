require 'rails_helper'

RSpec.describe "Albums", type: :request do
  describe "GET /albums" do
    let!(:album_abc) { create(:album, title: 'abc') }
    let!(:album_xyz) { create(:album, title: 'xyz') }

    context "when querying by title" do
      it "returns matching albums in JSON" do
        get albums_path, params: { query: 'abc' }, as: :json
        json = JSON.parse(response.body)
        titles = json.map { |a| a["title"] }
        expect(titles).to include('abc')
        expect(titles).not_to include('xyz')
        expect(response).to have_http_status(:ok)
      end
    end

    context "when no albums match" do
      it "returns an empty array" do
        get albums_path, params: { query: 'notfound' }, as: :json
        json = JSON.parse(response.body)
        expect(json).to eq([])
        expect(response).to have_http_status(:ok)
      end
    end

    context "when query param is missing" do
      it "returns all albums" do
        get albums_path, as: :json
        json = JSON.parse(response.body)
        titles = json.map { |a| a["title"] }
        expect(titles).to include('abc', 'xyz')
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /albums" do
    let!(:artist) { create(:artist) }
    let(:album_params) { { album: { artist_id: artist.id, title: "New Album" } } }

    context "as an admin", as_logged_in_admin: true do
      it "creates an album" do
        post albums_path, params: album_params, as: :json
        expect(response).to have_http_status(:created)
      end
    end

    context "as a standard user", as_logged_in_user: true do
      it "is unauthorized" do
        post albums_path, params: album_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when not logged in" do
      it "is unauthorized" do
        post albums_path, params: album_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /albums/:id" do
    let!(:album) { create(:album) }
    let(:update_params) { { album: { title: "Updated Title" } } }

    context "as an admin", as_logged_in_admin: true do
      it "updates the album" do
        patch album_path(album), params: update_params, as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context "as a standard user", as_logged_in_user: true do
      it "is unauthorized" do
        patch album_path(album), params: update_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when not logged in" do
      it "is unauthorized" do
        patch album_path(album), params: update_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /albums/:id" do
    let!(:artist) { create(:artist) }

    context "as an admin", as_logged_in_admin: true do
      it "destroys album with no songs" do
        album = create(:album, artist: artist)
        delete album_path(album), as: :json
        expect(response).to have_http_status(:no_content)
        expect(Album.exists?(album.id)).to be false
      end

      it "does not destroy album with songs" do
        album = create(:album, artist: artist)
        create(:song, album: album)
        delete album_path(album), as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Cannot delete record because dependent songs exist")
        expect(Album.exists?(album.id)).to be true
      end
    end

    context "as a standard user", as_logged_in_user: true do
      it "is unauthorized" do
        album = create(:album, artist: artist)
        delete album_path(album), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when not logged in" do
      it "is unauthorized" do
        album = create(:album, artist: artist)
        delete album_path(album), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
