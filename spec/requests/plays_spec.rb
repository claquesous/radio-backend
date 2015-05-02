require 'rails_helper'

RSpec.describe "Plays", type: :request do
  describe "GET /plays" do
    it "works! (now write some real specs)" do
      get plays_path
      expect(response).to have_http_status(200)
    end
  end
end
