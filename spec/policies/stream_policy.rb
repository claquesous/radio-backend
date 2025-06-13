require 'rails_helper'

RSpec.describe StreamPolicy do
  subject { described_class }

  before(:each) do
    @stream = build(:stream)
  end

  permissions :show? do
    it "grants access if stream is owned by user" do
      expect(subject).to permit(@stream.user, @stream)
    end

    it "denies access if stream is owned by another user" do
      expect(subject).not_to permit(User.new, @stream)
    end

  end
end

