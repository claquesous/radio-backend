require 'rails_helper'

RSpec.describe SongPolicy, type: :policy do
  let(:user) { build(:user) }
  let(:admin) { build(:user, admin: true) }
  let(:song) { build(:song) }
  let(:nil_user) { nil }

  subject { described_class }

  permissions :show? do
    it "grants access to all users" do
      expect(subject).to permit(user, song)
      expect(subject).to permit(admin, song)
    end

    
  end

  [:create?, :update?, :destroy?].each do |action|
    permissions action do
      it "grants access to admin" do
        expect(subject).to permit(admin, song)
      end

      it "denies access to non-admins" do
        expect(subject).not_to permit(user, song)
      end

      
    end
  end
end
