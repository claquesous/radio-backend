require 'rails_helper'

RSpec.describe Album, type: :model do
  subject { described_class.new(artist: build(:artist)) }

  it { should validate_presence_of(:title).with_message(/can't be blank/) }
  it { should belong_to(:artist) }
  it { should have_many(:songs).dependent(:restrict_with_error) }
end
