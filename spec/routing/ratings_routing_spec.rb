require "rails_helper"

RSpec.describe RatingsController, type: :routing do
  describe "routing" do

    it "routes to #create" do
      expect(:post => "/admin/streams/1/ratings").to route_to("ratings#create", stream_id: "1")
    end

    it "routes to #create" do
      expect(:post => "/api/streams/1/ratings").to route_to("ratings#create", stream_id: "1", format: :json)
    end

  end
end
