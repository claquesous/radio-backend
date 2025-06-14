require 'rails_helper'

RSpec.describe ArtistPolicy, type: :policy do
  let(:user) { build(:user) }
  let(:admin) { build(:user, admin: true) }
  let(:artist) { build(:artist) }

  subject { described_class }

  permissions :show? do
    it "grants access to all users" do
      expect(subject).to permit(user, artist)
      expect(subject).to permit(admin, artist)
    end
  end

  [:create?, :update?, :destroy?].each do |action|
    permissions action do
      it "grants access to admin" do
        expect(subject).to permit(admin, artist)
      end

      it "denies access to non-admins" do
        expect(subject).not_to permit(user, artist)
      end
    end
  end
end
