require "rails_helper"

RSpec.describe ChoosersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/choosers").to route_to("choosers#index")
    end

    it "routes to #new" do
      expect(get: "/choosers/new").to route_to("choosers#new")
    end

    it "routes to #show" do
      expect(get: "/choosers/1").to route_to("choosers#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/choosers/1/edit").to route_to("choosers#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/choosers").to route_to("choosers#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/choosers/1").to route_to("choosers#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/choosers/1").to route_to("choosers#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/choosers/1").to route_to("choosers#destroy", id: "1")
    end
  end
end
