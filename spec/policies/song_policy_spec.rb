require 'rails_helper'

RSpec.describe SongPolicy do
  subject { described_class }

  let(:admin) { build(:user, admin: true) }
  let(:user) { build(:user, admin: false) }
  let(:song) { build(:song) }

  permissions :create?, :update?, :destroy? do
    it "permits admin" do
      expect(subject).to permit(admin, song)
    end

    it "forbids standard user" do
      expect(subject).not_to permit(user, song)
    end
  end
end

