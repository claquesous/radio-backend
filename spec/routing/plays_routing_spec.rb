require "rails_helper"

RSpec.describe PlaysController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/plays").to route_to("plays#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/plays/1").to route_to("plays#show", :id => "1", format: :json)
    end

    it "routes to #create" do
      expect(:post => "/private/streams/1/plays").to route_to("plays#create", stream_id: "1")
    end

  end
end
