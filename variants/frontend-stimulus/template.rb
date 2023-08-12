source_paths.unshift(File.dirname(__FILE__))

TERMINAL.puts_header "Setting up stimulus.js"

yarn_add_dependencies %w[
  @hotwired/stimulus
  @hotwired/stimulus-webpack-helpers
]

directory "app/frontend/stimulus/controllers"
directory "app/frontend/test"

prepend_to_file "app/frontend/packs/application.js" do
  <<~EO_JS_IMPORTS
    import { Application } from '@hotwired/stimulus';
    import { definitionsFromContext } from '@hotwired/stimulus-webpack-helpers';
  EO_JS_IMPORTS
end

append_to_file "app/frontend/packs/application.js" do
  <<~EO_JS_SETUP

    // Set up stimulus.js https://stimulus.hotwired.dev/
    const application = Application.start();
    const context = require.context(
      '../stimulus/controllers',
      true,
      /.(js|ts)$/u
    );

    application.load(definitionsFromContext(context));

    // If you don't want to load all Stimulus controllers in this pack, you
    // can either use separate folders for each set of controllers you want to
    // load or you can remove the `definitionsFromContext` stuff here and
    // instead import each controller explicitly e.g.
    //
    //   import HelloController from "../stimulus/controllers/hello_controller"
    //   application.register("hello", HelloController)
    //   import OtherController from "../stimulus/controllers/other_controller"
    //   application.register("other", OtherController)

    // Configure stimulus development experience
    application.debug = false;
    // window.Stimulus = application;
  EO_JS_SETUP
end

# We need the major version of the 'jest', '@jest/types', 'ts-jest' packages to
# match so we can only upgrade jest when there are compatible versions available
jest_major_version = "29"

yarn_add_dev_dependencies %W[
  @testing-library/dom
  @testing-library/jest-dom
  @testing-library/user-event
  eslint-plugin-jest
  eslint-plugin-jest-formatting
  eslint-plugin-jest-dom
  eslint-plugin-testing-library
  jest-environment-jsdom
  jest@#{jest_major_version}
]

copy_file ".eslintrc.js", force: true
copy_file "jest.config.js"

package_json.merge! do |pj|
  {
    "scripts" => pj.fetch("scripts", {}).merge({
      "test" => "jest",
      "watch-tests" => "jest --watch"
    })
  }
end

append_to_file "bin/ci-run" do
  <<~JEST
    echo "* ******************************************************"
    echo "* Running JS tests"
    echo "* ******************************************************"
    #{package_json.manager.native_run_command("test", ["--coverage"]).join(" ")}
  JEST
end
