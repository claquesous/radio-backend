require 'rails_helper'

RSpec.describe "albums/index", type: :view do
  before(:each) do
    assign(:albums, [
      Album.create!(
        :artist => nil,
        :title => "Title",
        :sort => "Sort",
        :slug => "Slug",
        :tracks => "",
        :id3_genre => "Id3 Genre",
        :record_label => "Record Label"
      ),
      Album.create!(
        :artist => nil,
        :title => "Title",
        :sort => "Sort",
        :slug => "Slug",
        :tracks => "",
        :id3_genre => "Id3 Genre",
        :record_label => "Record Label"
      )
    ])
  end

  it "renders a list of albums" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Sort".to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Id3 Genre".to_s, :count => 2
    assert_select "tr>td", :text => "Record Label".to_s, :count => 2
  end
end
