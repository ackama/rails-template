module Users
  class SessionsController < Devise::SessionsController
    ##
    # We want to make sure that when a user logs out (i.e. destroys their
    # session) then the session cookie they had cannot be used again. We
    # achieve this by overriding the built-in devise implementation of
    # `Devise::SessionsController#destroy` action to invalidate all existing
    # user sessions and then call `super` to run the built-in devise
    # implementation of the method.
    #
    # References
    #   * https://github.com/plataformatec/devise/issues/3031
    #   * http://maverickblogging.com/logout-is-broken-by-default-ruby-on-rails-web-applications/
    #   * https://makandracards.com/makandra/53562-devise-invalidating-all-sessions-for-a-user
    #
    def destroy
      current_user.invalidate_all_sessions!
      super
    end
  end
end
