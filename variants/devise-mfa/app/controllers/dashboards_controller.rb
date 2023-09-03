##
# This is an example controller which you should remove from your application.
# It demonstrates how to create a controller which requires users to be
# authenticated before running any of its actions.
#
class DashboardsController < ApplicationController
  before_action :authenticate_user!

  # Only authenticated users can see the dashboard
  def show
    authorize :dashboard
  end
end
