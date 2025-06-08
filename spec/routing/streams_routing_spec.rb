require "rails_helper"

RSpec.describe StreamsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get: "/api/streams").to route_to("streams#index", format: :json)
    end

    it "routes to #show" do
      expect(get: "/api/streams/1").to route_to("streams#show", id: "1", format: :json)
    end

  end
end
