require 'rails_helper'

RSpec.describe "streams/edit", type: :view do
  let(:stream) {
    create(:stream)
  }

  before(:each) do
    assign(:stream, stream)
  end

  it "renders the edit stream form" do
    render

    assert_select "form[action=?][method=?]", stream_path(stream), "post" do

      assert_select "input[name=?]", "stream[name]"

      assert_select "input[name=?]", "stream[user_id]"
    end
  end
end
