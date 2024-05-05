require "rails_helper"

RSpec.describe SongsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/songs").to route_to("songs#index")
    end

    it "routes to #new" do
      expect(:get => "/admin/songs/new").to route_to("songs#new")
    end

    it "routes to #show" do
      expect(:get => "/admin/songs/1").to route_to("songs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/admin/songs/1/edit").to route_to("songs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admin/songs").to route_to("songs#create")
    end

    it "routes to #update" do
      expect(:put => "/admin/songs/1").to route_to("songs#update", :id => "1")
    end

    it "routes to #index" do
      expect(:get => "/api/songs").to route_to("songs#index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/songs/1").to route_to("songs#show", :id => "1", format: :json)
    end

  end
end
