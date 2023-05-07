# Renders the home page.
class DashboardsController < ApplicationController
  before_action :authenticate_user!

  # TODO: is adding this public/dashboard too much for the template?
  def show
  end
end
