require "capybara/selenium/driver"

# Patches how Capybara resets storage so it no longer passes a wildcard
# origin, as Chrome 158+ rejects that as an invalid url
#
# see https://github.com/teamcapybara/capybara/issues/2865
module ClearStorageWithoutWildcardOrigin
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    types = params[:storageTypes].to_s.split(",")
    super("Network.clearBrowserCookies") if types.delete("cookies")

    origin = Capybara.current_session.server&.base_url
    super(cmd, params.merge(origin:, storageTypes: types.join(","))) if origin && types.any?
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ClearStorageWithoutWildcardOrigin)
