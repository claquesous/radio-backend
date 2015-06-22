require "rails_helper"

RSpec.describe ListenersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/listeners").to route_to("listeners#index")
    end

    it "routes to #new" do
      expect(:get => "/listeners/new").to route_to("listeners#new")
    end

    it "routes to #show" do
      expect(:get => "/listeners/1").to route_to("listeners#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/listeners/1/edit").to route_to("listeners#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/listeners").to route_to("listeners#create")
    end

    it "routes to #update" do
      expect(:put => "/listeners/1").to route_to("listeners#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/listeners/1").to route_to("listeners#destroy", :id => "1")
    end

  end
end
