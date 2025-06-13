require 'rails_helper'

RSpec.describe Request, type: :model do
  describe "associations" do
    
    
    
    
  end

  describe "validations" do
    
    
  end

  describe "#not_throttled" do
    let(:user) { create(:user) }
    let(:stream) { create(:stream) }
    let(:song) { create(:song) }

    it "does not throttle with fewer than 3 requests" do
      2.times { create(:request, user: user, requested_at: 1.minute.ago) }
      expect(build(:request, user: user, requested_at: Time.now)).to be_valid
    end

    it "does not throttle for older requests" do
      2.times { create(:request, user: user, requested_at: 2.hours.ago) }
      2.times { create(:request, user: user, requested_at: 1.minute.ago) }
      expect(build(:request, user: user, requested_at: Time.now)).to be_valid
    end

    it "limits users to 3 requests per hour" do
      3.times { create(:request, user: user, requested_at: 1.minute.ago) }
      expect(build(:request, user: user, requested_at: Time.now)).to_not be_valid
    end

    it "allows unlimited requests to the stream owner" do
      3.times { create(:request, stream: stream, user: stream.user, requested_at: 1.minute.ago) }
      expect(build(:request, stream: stream, user: stream.user, requested_at: Time.now)).to be_valid
    end
  end
end
