require 'rails_helper'

RSpec.describe Person, type: :model do
  it { should validate_presence_of(:name) }
  it { should have_many(:credits) }
  it { should have_many(:songs).through(:credits) }
end

RSpec.describe Person, ".for" do
  let(:mbid) { "b1a9c0e9-d987-4042-ae91-78d6a3267d69" }

  it "finds a person by external id" do
    person = create(:person, name: "Martin Hannett", mb_artist_id: mbid)
    expect(Person.for(name: "M. Hannett", mb_artist_id: mbid)).to eq(person)
  end

  it "merges a Discogs credit into the same-named MusicBrainz person" do
    person = create(:person, name: "Martin Hannett", mb_artist_id: mbid)
    expect(Person.for(name: "martin hannett", discogs_id: 42)).to eq(person)
    expect(person.reload.discogs_id).to eq(42)
  end

  it "creates a new person when the name's id slot is already taken" do
    create(:person, name: "John Smith", discogs_id: 1)
    other = Person.for(name: "John Smith", discogs_id: 2)
    expect(other).to have_attributes(name: "John Smith", discogs_id: 2)
    expect(Person.where(name: "John Smith").count).to eq(2)
  end

  it "creates a person without external ids" do
    expect { Person.for(name: "Nobody") }.to change(Person, :count).by(1)
  end
end
