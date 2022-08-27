source_paths.unshift(File.dirname(__FILE__))

puts "Setting up stimulus.js"

yarn_add_dependencies %w[
  @hotwired/stimulus
  @hotwired/stimulus-webpack-helpers
]

if TEMPLATE_CONFIG.use_typescript?
  copy_file "variants/frontend-stimulus/hello_controller.ts", "app/frontend/javascript/controllers/hello_controller.ts"
else
  copy_file "variants/frontend-stimulus/hello_controller.js", "app/frontend/javascript/controllers/hello_controller.js"
end

prepend_to_file "app/frontend/packs/application.js" do
  <<~EO_JS_IMPORTS
    import { Application } from '@hotwired/stimulus';
    import { definitionsFromContext } from '@hotwired/stimulus-webpack-helpers';
  EO_JS_IMPORTS
end

if TEMPLATE_CONFIG.use_typescript?
  append_to_file "app/frontend/packs/application.js" do
    <<~EO_TS_SETUP
      // TODO

      // Set up stimulus.js https://stimulus.hotwired.dev/
      // const application = Application.start();
      // const controllerFilesRegex = /\.js$/u;
      // const context = require.context('./controllers', true, controllerFilesRegex);

      // application.load(definitionsFromContext(context));

      // // Configure stimulus development experience
      // application.debug = false;
      // // window.Stimulus = application;
    EO_TS_SETUP
  end
else
  append_to_file "app/frontend/packs/application.js" do
    <<~EO_JS_SETUP

      // Set up stimulus.js https://stimulus.hotwired.dev/
      const application = Application.start();
      const context = require.context('../javascript/controllers', true, /\.js$/u);

      application.load(definitionsFromContext(context));

      // Configure stimulus development experience
      application.debug = false;
      // window.Stimulus = application;
    EO_JS_SETUP
  end
end
