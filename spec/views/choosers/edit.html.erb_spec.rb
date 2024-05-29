require 'rails_helper'

RSpec.describe "choosers/edit", type: :view do
  let(:chooser) {
    create(:chooser)
  }

  before(:each) do
    assign(:chooser, chooser)
  end

  it "renders the edit chooser form" do
    render

    assert_select "form[action=?][method=?]", stream_chooser_path(chooser.stream, chooser), "post" do

      assert_select "input[name=?]", "chooser[featured]"

      assert_select "input[name=?]", "chooser[rating]"
    end
  end
end
