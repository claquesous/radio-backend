require "rails_helper"

RSpec.describe RequestsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/streams/1/requests").to route_to("requests#index", stream_id: "1")
    end

    it "routes to #show" do
      expect(:get => "/admin/streams/1/requests/1").to route_to("requests#show", :id => "1", stream_id: "1")
    end

  end
end
