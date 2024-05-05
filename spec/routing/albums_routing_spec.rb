require "rails_helper"

RSpec.describe AlbumsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/albums").to route_to("albums#index")
    end

    it "routes to #new" do
      expect(:get => "/admin/albums/new").to route_to("albums#new")
    end

    it "routes to #show" do
      expect(:get => "/admin/albums/1").to route_to("albums#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/admin/albums/1/edit").to route_to("albums#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admin/albums").to route_to("albums#create")
    end

    it "routes to #update" do
      expect(:put => "/admin/albums/1").to route_to("albums#update", :id => "1")
    end

    it "routes to #index" do
      expect(:get => "/api/albums").to route_to("albums#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/albums/1").to route_to("albums#show", :id => "1", format: :json)
    end

  end
end
