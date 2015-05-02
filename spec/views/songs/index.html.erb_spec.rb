require 'rails_helper'

RSpec.describe "songs/index", type: :view do
  before(:each) do
    assign(:songs, [
      Song.create!(
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
      ),
      Song.create!(
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
      )
    ])
  end

  it "renders a list of songs" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Sort".to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Path".to_s, :count => 2
  end
end
