require 'rails_helper'

RSpec.describe "Artists", type: :request do
  describe "GET /artists" do
    let!(:artist_abc) { create(:artist, name: 'abc') }
    let!(:artist_xyz) { create(:artist, name: 'xyz') }

    context "when querying by name" do
      it "returns matching artists in JSON" do
        get artists_url, params: { query: 'abc' }, as: :json
        json = JSON.parse(response.body)
        names = json.map { |a| a["name"] }
        expect(names).to include('abc')
        expect(names).not_to include('xyz')
        expect(response).to have_http_status(:ok)
      end
    end

    context "when no artists match" do
      it "returns an empty array" do
        get artists_url, params: { query: 'notfound' }, as: :json
        json = JSON.parse(response.body)
        expect(json).to eq([])
        expect(response).to have_http_status(:ok)
      end
    end

    context "when query param is missing" do
      it "returns all artists" do
        get artists_url, as: :json
        json = JSON.parse(response.body)
        names = json.map { |a| a["name"] }
        expect(names).to include('abc', 'xyz')
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE /artists/:id" do
    context "as an admin", as_logged_in_admin: true do
      it "destroys artist with no songs or albums" do
        artist = create(:artist)
        delete artist_path(artist), as: :json
        expect(response).to have_http_status(:no_content)
        expect(Artist.exists?(artist.id)).to be false
      end

      it "does not destroy artist with songs" do
        artist = create(:artist)
        create(:song, artist: artist)
        delete artist_path(artist), as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Cannot delete record because dependent songs exist")
        expect(Artist.exists?(artist.id)).to be true
      end

      it "does not destroy artist with albums" do
        artist = create(:artist)
        create(:album, artist: artist)
        delete artist_path(artist), as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Cannot delete record because dependent albums exist")
        expect(Artist.exists?(artist.id)).to be true
      end
    end

    context "as a standard user", as_logged_in_user: true do
      it "is unauthorized" do
        artist = create(:artist)
        delete artist_path(artist), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when not logged in" do
      it "is unauthorized" do
        artist = create(:artist)
        delete artist_path(artist), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
