require "rails_helper"

RSpec.describe AuthsController, type: :routing do
  describe "routing" do

    it "routes to #create" do
      expect(:post => "/api/login").to route_to("auths#create", format: :json)
    end

    it "routes to #destroy" do
      expect(:delete => "/api/logout").to route_to("auths#destroy", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/private/auth").to route_to("auths#show")
    end

  end
end
