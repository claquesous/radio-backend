require 'rails_helper'

RSpec.describe Credit, type: :model do
  subject { build(:credit) }
  it { should belong_to(:song) }
  it { should belong_to(:person) }
  it { should validate_inclusion_of(:role).in_array(Credit::ROLES) }
  it { should validate_inclusion_of(:source).in_array(Credit::SOURCES) }

  it "allows one credit per song, person, role and source" do
    credit = create(:credit)
    duplicate = build(:credit, song: credit.song, person: credit.person)
    expect(duplicate).not_to be_valid
    expect(build(:credit, song: credit.song, person: credit.person, role: "engineer")).to be_valid
  end

  it "links songs and people both ways" do
    credit = create(:credit)
    expect(credit.song.people).to eq([credit.person])
    expect(credit.person.songs).to eq([credit.song])
  end
end
