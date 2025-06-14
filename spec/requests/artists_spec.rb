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
end
