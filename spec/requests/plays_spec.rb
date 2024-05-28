require 'rails_helper'

RSpec.describe "Plays", type: :request do
  describe "GET /plays" do
    it "works! (now write some real specs)" do
      stream = create(:stream)
      get stream_plays_path(stream)
      expect(response).to have_http_status(200)
    end
  end
end
