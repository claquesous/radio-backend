require 'rails_helper'

RSpec.describe "Artists", type: :request do
  describe "GET /artists" do
    it "queries by name" do
      create(:artist, name: 'abc')
      create(:artist, name: 'xyz')

      get artists_url, params: { query: 'abc' }
      expect(response.body).to include('abc')
      expect(response.body).to_not include('xyz')
    end
  end
end
