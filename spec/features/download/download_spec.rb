require "rails_helper"

describe "Download page", type: :feature, js: true do
  before { visit downloadpage_path }

  context "when a User (not signed in) on the download page", skip: "Example of download" do
    it "show download link" do
      expect(page).to have_link "Download"
    end

    it "download a example.png file" do
      click_link "Download"
      DownloadHelpers.clear_downloads
      expect(DownloadHelpers.download_file).to eq("example.png")
      DownloadHelpers.clear_downloads
    end
  end
end
