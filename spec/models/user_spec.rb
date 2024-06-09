require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#set_initial_admin" do
    it "sets initial user as admin" do
      user = create(:user)
      expect(user).to be_admin
    end

    it "sets additional users as not admin" do
      create(:user)
      user2 = create(:user)
      expect(user2).to_not be_admin
    end
  end
end
