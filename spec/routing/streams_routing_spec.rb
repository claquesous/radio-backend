require "rails_helper"

RSpec.describe StreamsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/streams").to route_to("streams#index")
    end

    it "routes to #new" do
      expect(get: "/admin/streams/new").to route_to("streams#new")
    end

    it "routes to #show" do
      expect(get: "/admin/streams/1").to route_to("streams#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/streams/1/edit").to route_to("streams#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/admin/streams").to route_to("streams#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/streams/1").to route_to("streams#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/streams/1").to route_to("streams#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/streams/1").to route_to("streams#destroy", id: "1")
    end

    it "routes to #index" do
      expect(get: "/api/streams").to route_to("streams#index", format: :json)
    end

    it "routes to #show" do
      expect(get: "/api/streams/1").to route_to("streams#show", id: "1", format: :json)
    end

  end
end
