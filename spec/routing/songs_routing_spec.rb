require "rails_helper"

RSpec.describe SongsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/songs").to route_to("songs#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/songs/1").to route_to("songs#show", :id => "1", format: :json)
    end

  end
end
