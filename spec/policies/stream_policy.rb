require 'rails_helper'

RSpec.describe StreamPolicy, type: :policy do
  let(:user) { build(:user) }
  let(:admin) { build(:user, admin: true) }
  let(:stream) { build(:stream, user: user) }
  let(:other_user) { build(:user) }

  subject { described_class }

  permissions :show? do
    it "grants access if stream is owned by user" do
      expect(subject).to permit(user, stream)
    end

    it "denies access if stream is owned by another user" do
      expect(subject).not_to permit(other_user, stream)
    end

    it "grants access to admin" do
      expect(subject).to permit(admin, stream)
    end
  end
end
