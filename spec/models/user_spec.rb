require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#set_initial_admin" do
    it "sets initial user as admin" do
      user = create(:user_with_callback)
      expect(user).to be_admin
    end

    it "sets additional users as not admin" do
      create(:user_with_callback)
      user2 = create(:user_with_callback)
      expect(user2).to_not be_admin
    end
  end
end
