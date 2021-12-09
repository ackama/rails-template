# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  # These directives define a quite strict policy by default. You may have to
  # loosen this policy as you add elements to the app. Some examples of common
  # additions are shown below.
  #
  policy.default_src :self
  policy.font_src    :self
  policy.img_src     :data, :self
  policy.object_src  :none
  policy.script_src  :self
  policy.style_src   :self

  # Allow inline-styles
  # ###################
  #
  # * The use of both kind of quotes is required here because the value as it
  #   appears in the CSP header must be surrounded by single quotes.
  # * Try to avoid enabling this if you can
  # * IMPORTANT: you can't just uncomment these lines to make this work - you
  #   need to merge the example into your existing call to the appropriate
  #   `*_src` method.
  #
  # policy.style_src  :self, "'unsafe-inline'"

  # Use a separate host for assets e.g. CDN
  # #######################################
  #
  # * This example adds the external host to the `default_src` policy meaning
  #   that any kind of asset can be loaded from it. You should be more
  #   targeted if you can e.g. if the external host is only going to serve
  #   images then use `policy.img_src` instead.
  # * IMPORTANT: you can't just uncomment these lines to make this work - you
  #   need to merge the example into your existing call to the appropriate
  #   `*_src` method.
  #
  # asset_host = if Rails.env.development? || Rails.env.test?
  #                "http://#{Rails.application.secrets.asset_host}"
  #              else
  #                "https://#{Rails.application.secrets.asset_host}"
  #              end
  # policy.default_src :self, asset_host

  # Use an S3 bucket for assets
  # ###########################
  #
  # * This example adds the S3 bucket to the `default_src` policy meaning that
  #   any kind of asset can be loaded from it. You should be more targetted if
  #   you can e.g. if the bucket is only going to serve images then use
  #   `policy.img_src` instead.
  # * IMPORTANT: you can't just uncomment these lines to make this work - you
  #   need to merge the example into your existing call to the appropriate
  #   `*_src` method.
  #
  # s3_bucket_url = "https://my-app-assets-#{Rails.env.dasherize}.s3.amazonaws.com"
  # policy.default_src :self, s3_bucket_url

  # Use Google fonts
  # ################
  #
  # * Instructions: https://content-security-policy.com/examples/google-fonts/
  # * IMPORTANT: you can't just uncomment these lines to make this work - you
  #   need to merge the example into your existing call to the appropriate
  #   `*_src` method.
  #
  # policy.font_src :self, "https://fonts.gstatic.com"
  # policy.style_src :self, "https://fonts.googleapis.com"

  # Use Google Tag Manager or Google Analytics
  # ##########################################
  #
  # * Instructions: https://developers.google.com/tag-manager/web/csp
  # * You can use the nonce version. Rails generates the nonce which you can use as follows:
  #
  #     <%= javascript_tag nonce: true do -%>
  #         <!-- Google tag manager or analytics snippet goes here
  #     <% end -%>
  #
  # https://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html#method-i-javascript_tag
  # for details.

  # Allow webpack-dev-server to use websockets in development
  # #########################################################
  #
  # * We want to minimize differences in the CSP header between environments so
  #   that we can find and fix CSP issues in development but enabling the
  #   webpack-dev-server to communicate over websockets is an exception.
  #
  policy.connect_src :self, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?

  # Enable CSP reporting
  # ####################
  #
  # You should enable a reporting URL so you can find and fix any issues your
  # users encounter caused by CSP in production.
  #
  # If you app is using https://sentry.io then you can use the URL they provide
  # for your app to report CSP issues - see
  # https://docs.sentry.io/error-reporting/security-policy-reporting/ for
  # details
  #
  # policy.report_uri "https://o250825.ingest.sentry.io/api/1409600/security/?sentry_key=SOMETHING"
end

# ###############
# Configure nonce
# ###############

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# ################################
# Configure reporting vs enforcing
# ################################
#
# Report CSP violations to a specified URI. For further information see the
# following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
#
# We default to turning on enforcement in all environments so that we can catch
# issues early in development before they hit staging or production.
#
Rails.application.config.content_security_policy_report_only = false


