require "rails_helper"

RSpec.describe ListenersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/listeners").to route_to("listeners#index")
    end

    it "routes to #show" do
      expect(:get => "/admin/listeners/1").to route_to("listeners#show", :id => "1")
    end

    it "routes to #index" do
      expect(:get => "/api/listeners").to route_to("listeners#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/listeners/1").to route_to("listeners#show", :id => "1", format: :json)
    end

  end
end
