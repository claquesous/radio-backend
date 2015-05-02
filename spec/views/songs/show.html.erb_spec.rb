require 'rails_helper'

RSpec.describe "songs/show", type: :view do
  before(:each) do
    @song = assign(:song, Song.create!(
      :album => "",
      :artist => nil,
      :title => "Title",
      :sort => "Sort",
      :slug => "Slug",
      :track => "",
      :time => "",
      :featured => false,
      :live => false,
      :remix => false,
      :rating => "",
      :path => "Path"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Sort/)
    expect(rendered).to match(/Slug/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Path/)
  end
end
