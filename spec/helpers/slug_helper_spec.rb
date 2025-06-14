require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SlugHelper. For example:
#
# describe SlugHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SlugHelper, type: :helper do
  describe "#to_slug" do
    it "lowercases" do
      expect(helper.to_slug("Title")).to eq("title")
    end

    it "replaces special characters with dashes" do
      expect(helper.to_slug("my#life")).to eq("my-life")
    end

    it "strips a trailing dash" do
      expect(helper.to_slug("why?")).to eq("why")
    end
  end
end

