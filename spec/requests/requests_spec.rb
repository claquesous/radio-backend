require 'rails_helper'

RSpec.describe "Requests", type: :request do
  describe "GET /requests" do
    it "works! (now write some real specs)" do
      stream = create(:stream)
      get stream_requests_path(stream)
      expect(response).to have_http_status(200)
    end
  end
end
