require 'rails_helper'

RSpec.describe AlbumPolicy do
  subject { described_class }

  let(:admin) { build(:user, admin: true) }
  let(:user) { build(:user, admin: false) }
  let(:album) { build(:album) }

  permissions :create?, :update?, :destroy? do
    it "permits admin" do
      expect(subject).to permit(admin, album)
    end

    it "forbids standard user" do
      expect(subject).not_to permit(user, album)
    end
  end
end
