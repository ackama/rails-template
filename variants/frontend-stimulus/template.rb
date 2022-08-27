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
      const controllerFilesRegex = /\.js$/u;
      const context = require.context('./controllers', true, controllerFilesRegex);

      application.load(definitionsFromContext(context));

      // Configure stimulus development experience
      application.debug = false;
      // window.Stimulus = application;
    EO_JS_SETUP
  end
end

# Webpacker does not like const context = require.context('./controllers', true, controllerFilesRegex) - it throws this warning
# WARNING in ./app/frontend/packs/application.js 56:16-23
# Critical dependency: require function is used in a way in which dependencies cannot be statically extracted
#     at CommonJsRequireContextDependency.getWarnings (/Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/webpack/lib/dependencies/ContextDependency.js:102:18)
#     at Compilation.reportDependencyErrorsAndWarnings (/Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/webpack/lib/Compilation.js:3132:24)
#     at /Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/webpack/lib/Compilation.js:2729:28
#     at eval (eval at create (/Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/tapable/lib/HookCodeFactory.js:33:10), <anonymous>:42:1)
#     at /Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/webpack/lib/FlagDependencyExportsPlugin.js:385:11
#     at /Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/neo-async/async.js:2830:7
#     at Object.each (/Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/neo-async/async.js:2850:39)
#     at /Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/webpack/lib/FlagDependencyExportsPlugin.js:361:18
#     at /Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/neo-async/async.js:2830:7
#     at Object.each (/Users/eoinkelly/Code/repos/rails-template/tmp/builds/tmpl_eoin_app/node_modules/neo-async/async.js:2850:39)
