require 'rails_helper'

RSpec.describe "ratings/new", type: :view do
  before(:each) do
    assign(:rating, Rating.new(
      :play => "",
      :up => false,
      :twitter_handle => "MyString"
    ))
  end

  it "renders new rating form" do
    render

    assert_select "form[action=?][method=?]", ratings_path, "post" do

      assert_select "input#rating_play[name=?]", "rating[play]"

      assert_select "input#rating_up[name=?]", "rating[up]"

      assert_select "input#rating_twitter_handle[name=?]", "rating[twitter_handle]"
    end
  end
end
