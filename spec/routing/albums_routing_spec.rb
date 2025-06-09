require "rails_helper"

RSpec.describe AlbumsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/albums").to route_to("albums#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/albums/1").to route_to("albums#show", :id => "1", format: :json)
    end

  end
end
