##
# This is an example controller which you should remove from your application.
# It demonstrates how to create a controller which requires users to be
# authenticated before running any of its actions.
#
class DashboardsController < ApplicationController
  before_action :authenticate_user!

  # TODO
  # without this controller there is no example of how to create an
  # authenticated controller - the Homecontroller is not authenticated. is that
  # a problem?
  def show
  end
end
