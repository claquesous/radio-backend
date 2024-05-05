require "rails_helper"

RSpec.describe RatingsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/ratings").to route_to("ratings#index")
    end

    it "routes to #show" do
      expect(:get => "/admin/ratings/1").to route_to("ratings#show", :id => "1")
    end

    it "routes to #index" do
      expect(:get => "/api/ratings").to route_to("ratings#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/ratings/1").to route_to("ratings#show", :id => "1", format: :json)
    end

  end
end
