require 'rails_helper'

RSpec.describe "artists/index", type: :view do
  before(:each) do
    assign(:artists, [
      create(:artist),
      create(:artist),
    ])
  end

  it "renders a list of artists" do
    render
    assert_select "tr>td", :text => "Artist Name".to_s, :count => 2
    assert_select "tr>td", :text => "artist-name".to_s, :count => 2
  end
end
