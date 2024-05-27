require 'rails_helper'

RSpec.describe "choosers/edit", type: :view do
  let(:chooser) {
    Chooser.create!(
      song: nil,
      stream: nil,
      featured: false,
      rating: 1.5
    )
  }

  before(:each) do
    assign(:chooser, chooser)
  end

  it "renders the edit chooser form" do
    render

    assert_select "form[action=?][method=?]", chooser_path(chooser), "post" do

      assert_select "input[name=?]", "chooser[song_id]"

      assert_select "input[name=?]", "chooser[stream_id]"

      assert_select "input[name=?]", "chooser[featured]"

      assert_select "input[name=?]", "chooser[rating]"
    end
  end
end
