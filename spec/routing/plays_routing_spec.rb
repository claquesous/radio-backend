require "rails_helper"

RSpec.describe PlaysController, type: :routing do
  describe "routing" do

    it "routes to #create" do
      expect(:post => "/private/streams/1/plays").to route_to("plays#create", stream_id: "1")
    end

    it "routes to #current" do
      expect(:get => "/private/streams/1/plays/current").to route_to("plays#current", stream_id: "1")
    end

  end
end
