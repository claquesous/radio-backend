require 'rails_helper'

RSpec.describe "/auths", type: :request do

  describe "GET /index" do
    it "renders a successful response" do
      play = create(:play)
      get stream_plays_url(play.stream)
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      play = create(:play)
      get stream_play_url(play.stream, play)
      expect(response).to be_successful
    end
  end
end
