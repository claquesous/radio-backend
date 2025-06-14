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
end
