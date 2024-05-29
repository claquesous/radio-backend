require "rails_helper"

RSpec.describe ChoosersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/streams/1/choosers").to route_to("choosers#index", stream_id: "1")
    end

    it "routes to #show" do
      expect(get: "/admin/streams/1/choosers/1").to route_to("choosers#show", stream_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/streams/1/choosers/1/edit").to route_to("choosers#edit", stream_id: "1", id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/streams/1/choosers/1").to route_to("choosers#update", stream_id: "1", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/streams/1/choosers/1").to route_to("choosers#update", stream_id: "1", id: "1")
    end
  end
end
