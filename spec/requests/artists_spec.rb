require 'rails_helper'

RSpec.describe "Artists", type: :request do
  let!(:artist_abc) { create(:artist, name: 'abc') }
  let!(:artist_xyz) { create(:artist, name: 'xyz') }

  before do
    allow_any_instance_of(ArtistsController).to receive(:authenticate_request)
  end

  describe "GET /artists" do
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

    context "when unauthenticated" do
      it "returns 401" do
        allow_any_instance_of(ArtistsController).to receive(:authenticate_request).and_call_original
        get artists_url, params: { query: 'abc' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
