require 'rails_helper'

RSpec.describe "ratings/edit", type: :view do
  before(:each) do
    @rating = assign(:rating, Rating.create!(
      :play => "",
      :up => false,
      :twitter_handle => "MyString"
    ))
  end

  it "renders the edit rating form" do
    render

    assert_select "form[action=?][method=?]", rating_path(@rating), "post" do

      assert_select "input#rating_play[name=?]", "rating[play]"

      assert_select "input#rating_up[name=?]", "rating[up]"

      assert_select "input#rating_twitter_handle[name=?]", "rating[twitter_handle]"
    end
  end
end
