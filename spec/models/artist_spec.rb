require 'rails_helper'

RSpec.describe Artist, type: :model do
  it { should validate_presence_of(:name).with_message(/can't be blank/) }
  it { should have_many(:songs).dependent(:restrict_with_error) }
  it { should have_many(:albums).dependent(:restrict_with_error) }
end
