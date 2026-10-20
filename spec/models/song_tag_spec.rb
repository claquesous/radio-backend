require 'rails_helper'

RSpec.describe SongTag, type: :model do
  subject { build(:song_tag) }
  it { should belong_to(:song) }
  it { should validate_presence_of(:tag) }
  it { should validate_inclusion_of(:source).in_array(SongTag::SOURCES) }
end
