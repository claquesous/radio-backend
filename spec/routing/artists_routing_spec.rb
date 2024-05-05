require "rails_helper"

RSpec.describe ArtistsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/artists").to route_to("artists#index")
    end

    it "routes to #new" do
      expect(:get => "/admin/artists/new").to route_to("artists#new")
    end

    it "routes to #show" do
      expect(:get => "/admin/artists/1").to route_to("artists#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/admin/artists/1/edit").to route_to("artists#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admin/artists").to route_to("artists#create")
    end

    it "routes to #update" do
      expect(:put => "/admin/artists/1").to route_to("artists#update", :id => "1")
    end

    it "routes to #index" do
      expect(:get => "/api/artists").to route_to("artists#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/artists/1").to route_to("artists#show", :id => "1", format: :json)
    end

  end
end
