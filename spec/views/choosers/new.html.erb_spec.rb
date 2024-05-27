require 'rails_helper'

RSpec.describe "choosers/new", type: :view do
  before(:each) do
    assign(:chooser, Chooser.new(
      song: nil,
      stream: nil,
      featured: false,
      rating: 1.5
    ))
  end

  it "renders new chooser form" do
    render

    assert_select "form[action=?][method=?]", choosers_path, "post" do

      assert_select "input[name=?]", "chooser[song_id]"

      assert_select "input[name=?]", "chooser[stream_id]"

      assert_select "input[name=?]", "chooser[featured]"

      assert_select "input[name=?]", "chooser[rating]"
    end
  end
end
