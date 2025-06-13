require 'rails_helper'

RSpec.describe SlugHelper, type: :helper do
  describe "#to_slug" do
    it "lowercases the string" do
      expect(helper.to_slug("Title")).to eq("title")
    end

    it "replaces special characters with dashes" do
      expect(helper.to_slug("my#life")).to eq("my-life")
    end

    it "strips a trailing dash" do
      expect(helper.to_slug("why?")).to eq("why")
    end

    it "handles empty string" do
      expect(helper.to_slug("")).to eq("")
    end

    it "handles nil input" do
      expect(helper.to_slug(nil)).to eq("")
    end

    it "collapses multiple special characters" do
      expect(helper.to_slug("foo!@#bar")).to eq("foo-bar")
    end

    it "removes leading and trailing dashes" do
      expect(helper.to_slug("!foo!")).to eq("foo")
    end
  end
end
