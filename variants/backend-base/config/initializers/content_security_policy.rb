# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    google_analytics_enabled = config.app.google_analytics_id.present?

    # These directives define a quite strict policy by default. You may have to
    # loosen this policy as you add elements to the app. Some examples of common
    # additions are shown below.
    #
    policy.default_src :self
    policy.font_src    :self
    policy.img_src     :self, :data, *[
      *(["*.googletagmanager.com", "*.google-analytics.com"] if google_analytics_enabled)
    ].compact
    policy.object_src  :none
    policy.script_src  :self, *[
      *(["*.googletagmanager.com"] if google_analytics_enabled)
    ].compact
    policy.style_src   :self
    policy.frame_src   :self, *[
      *(["*.googletagmanager.com"] if google_analytics_enabled)
    ].compact

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
    #                "http://#{config.app.asset_host}"
    #              else
    #                "https://#{config.app.asset_host}"
    #              end
    # policy.default_src :self, asset_host

    # Use an S3 bucket for assets
    # ###########################
    #
    # * This example adds the S3 bucket to the `default_src` policy meaning that
    #   any kind of asset can be loaded from it. You should be more targeted if
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

    policy.connect_src :self, *[
      *(["*.googletagmanager.com", "*.google-analytics.com", "*.analytics.google.com"] if google_analytics_enabled),
      # required for webpack-dev-server to be used in local development
      *(["http://localhost:3035", "ws://localhost:3035"] if Rails.env.development?)
    ].compact

    # Enable CSP reporting
    # ####################
    #
    # You should enable a reporting URL so you can find and fix any issues your
    # users encounter caused by CSP in production.
    #
    # If your app is using https://sentry.io then you can use the URL they provide
    # for your app to report CSP issues - see
    # https://docs.sentry.io/error-reporting/security-policy-reporting/ for
    # details
    #
    policy.report_uri ENV.fetch("SENTRY_CSP_HEADER_REPORT_ENDPOINT") if ENV.key?("SENTRY_CSP_HEADER_REPORT_ENDPOINT")

    # ###############
    # Configure nonce
    # ###############

    # Generate session nonces for permitted importmap, inline scripts, and inline styles.
    config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
    # config.content_security_policy_nonce_directives = %w(script-src style-src)

    # Automatically add `nonce` to `javascript_tag`, `javascript_include_tag`, and `stylesheet_link_tag`
    # if the corresponding directives are specified in `content_security_policy_nonce_directives`.
    # config.content_security_policy_nonce_auto = true

    # ################################
    # Configure reporting vs enforcing
    # ################################
    #
    # Report violations without enforcing the policy.
    # For further information see the following documentation:
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
    #
    # We default to turning on enforcement in all environments so that we can catch
    # issues early in development before they hit staging or production.
    #
    config.content_security_policy_report_only = false
  end
end
