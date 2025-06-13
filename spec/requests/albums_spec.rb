require 'rails_helper'

RSpec.describe "Albums", type: :request do
  describe "GET /albums" do
    it "queries by title" do
      create(:album, title: 'abc')
      create(:album, title: 'xyz')

      get albums_path, params: { query: 'abc' }
      expect(response.body).to include('abc')
      expect(response.body).to_not include('xyz')
    end
  end
end
