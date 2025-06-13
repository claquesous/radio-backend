require 'rails_helper'

RSpec.describe AlbumPolicy, type: :policy do
  let(:user) { build(:user) }
  let(:admin) { build(:user, admin: true) }
  let(:album) { build(:album) }
  let(:nil_user) { nil }

  subject { described_class }

  permissions :show? do
    it "grants access to all users" do
      expect(subject).to permit(user, album)
      expect(subject).to permit(admin, album)
    end

    
  end

  [:create?, :update?, :destroy?].each do |action|
    permissions action do
      it "grants access to admin" do
        expect(subject).to permit(admin, album)
      end

      it "denies access to non-admins" do
        expect(subject).not_to permit(user, album)
      end

      
    end
  end
end
