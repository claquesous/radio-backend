require 'rails_helper'

RSpec.describe "Auths", type: :request do
  let(:user) { create(:user, password: "password123", email: "test@example.com") }

  describe "POST /api/login" do
    context "with valid credentials" do
      it "returns a JWT token and user info" do
        post "/api/login", params: { email: user.email, password: "password123" }, as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key("token")
        expect(json["user"]["email"]).to eq(user.email)
        expect(json["user"]).to have_key("id")
      end

      it "sets a JWT cookie" do
        post "/api/login", params: { email: user.email, password: "password123" }, as: :json
        expect(response.cookies).to have_key("jwt")
      end
    end

    context "with invalid credentials" do
      it "returns 401 and error message" do
        post "/api/login", params: { email: user.email, password: "wrong" }, as: :json
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Email or password was invalid")
      end
    end
  end

  describe "DELETE /api/logout" do
    it "removes the JWT cookie and returns no content" do
      # Simulate login first
      post "/api/login", params: { email: user.email, password: "password123" }, as: :json
      expect(response.cookies).to have_key("jwt")
      delete "/api/logout"
      expect(response).to have_http_status(:no_content)
      expect(response.cookies["jwt"]).to be_nil
    end
  end

  describe "GET /private/auth" do
    context "when logged in" do
      it "returns 200" do
        post "/api/login", params: { email: user.email, password: "password123" }, as: :json
        get "/private/auth"
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not logged in" do
      it "returns 401" do
        get "/private/auth"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
