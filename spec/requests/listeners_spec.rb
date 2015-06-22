require 'rails_helper'

RSpec.describe "Listeners", type: :request do
  describe "GET /listeners" do
    it "works! (now write some real specs)" do
      get listeners_path
      expect(response).to have_http_status(200)
    end
  end
end
