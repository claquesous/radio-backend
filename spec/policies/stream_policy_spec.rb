require 'rails_helper'

RSpec.describe StreamPolicy do
  subject { described_class }

  let(:admin) { build(:user, admin: true) }
  let(:user) { build(:user, admin: false) }
  let(:stream) { build(:stream, user: user) }
  let(:other_user) { build(:user) }

  permissions :create?, :update? do
    it "permits standard user" do
      expect(subject).to permit(user, stream)
    end
  end

  permissions :show? do
    it "grants access if stream is owned by user" do
      expect(subject).to permit(user, stream)
    end

    it "denies access if stream is owned by another user" do
      expect(subject).not_to permit(other_user, stream)
    end
  end
end
