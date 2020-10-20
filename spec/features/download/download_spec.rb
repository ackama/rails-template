require "rails_helper"

RSpec.describe "Download page", js: true do
  before { visit downloadpage_path }

  context "A User (not signed in) on the dowanload page", skip: "Example of download" do
    it "should show download link" do
      expect(page).to have_link "Download"
    end

    it "should download a example.png file" do
      click_link "Download"
      DownloadHelpers.clear_downloads
      expect(DownloadHelpers.download_file).to eq("example.png")
      DownloadHelpers.clear_downloads
    end
  end
end
