# Setup Sentry
# ############

yarn_add_dependencies %w[@sentry/browser dotenv-webpack]

prepend_to_file "app/frontend/packs/application.js", "import * as Sentry from '@sentry/browser';"

append_to_file "app/frontend/packs/application.js" do
  <<~'EO_JS'

    // Initialize Sentry Error Reporting
    //
    // Import all your application's JS after this section because we need Sentry
    // to be initialized **before** we import any of our actual JS so that Sentry
    // can report errors from it.
    //
    Sentry.init({
      dsn: process.env.SENTRY_DSN,
      environment: process.env.SENTRY_ENV || process.env.RAILS_ENV
    });

    // Uncomment this Sentry by sending an exception every time the page loads.
    // Obviously this is a very noisy activity and we do have limits on Sentry so
    // you should never do this on a deployed environment.
    //
    // Sentry.captureException(new Error('Away-team to Enterprise, two to beam directly to sick bay...'));

    // Import all your application's JS here
    //
    // import '../javascript/example-1.js';
    // import { someFunc } from '../javascript/funcs.js';
  EO_JS
end

prepend_to_file "app/frontend/packs/application.js" do
  <<~'EO_JS'
    // The application.js pack is deferred by default which means that nothing imported
    // in this file will begin executing until after the page has loaded. This helps to
    // speed up page loading times, especially in apps that have large amounts of js.
    //
    // If you have javascript that *must* execute before the page has finished loading,
    // create a separate 'boot.js' pack in the frontend/packs directory and import any
    // required files in that. Also remember to add a separate pack_tag entry with:
    // <%= javascript_pack_tag "boot", "data-turbolinks-track": "reload" %>
    // to the views/layouts/application.html.erb file above the existing application pack tag.
    //
  EO_JS
end

gsub_file "config/initializers/content_security_policy.rb",
          /# policy.report_uri ".+"/,
          'policy.report_uri ENV["SENTRY_CSP_HEADER_REPORT_ENDPOINT"]'
