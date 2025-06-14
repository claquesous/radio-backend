require 'rails_helper'

RSpec.describe ArtistPolicy do
  subject { described_class }

  let(:admin) { build(:user, admin: true) }
  let(:user) { build(:user, admin: false) }
  let(:artist) { build(:artist) }

  permissions :create?, :update?, :destroy? do
    it "permits admin" do
      expect(subject).to permit(admin, artist)
    end

    it "forbids standard user" do
      expect(subject).not_to permit(user, artist)
    end
  end
end
