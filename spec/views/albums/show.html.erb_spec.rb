require 'rails_helper'

RSpec.describe "albums/show", type: :view do
  before(:each) do
    @album = assign(:album, Album.create!(
      :artist => nil,
      :title => "Title",
      :sort => "Sort",
      :slug => "Slug",
      :tracks => "",
      :id3_genre => "Id3 Genre",
      :record_label => "Record Label"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Sort/)
    expect(rendered).to match(/Slug/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Id3 Genre/)
    expect(rendered).to match(/Record Label/)
  end
end
