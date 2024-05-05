require "rails_helper"

RSpec.describe RequestsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/requests").to route_to("requests#index")
    end

    it "routes to #show" do
      expect(:get => "/admin/requests/1").to route_to("requests#show", :id => "1")
    end

    it "routes to #index" do
      expect(:get => "/api/requests").to route_to("requests#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/requests/1").to route_to("requests#show", :id => "1", format: :json)
    end

  end
end
