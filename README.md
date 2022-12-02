# Ackama Rails Template

[![Rails Template CI](https://github.com/ackama/rails-template/actions/workflows/ci.yml/badge.svg)](https://github.com/ackama/rails-template/actions/workflows/ci.yml)

This is a template you can use to create new Rails applications.

- [Ackama Rails Template](#ackama-rails-template)
  - [Background](#background)
  - [Features](#features)
  - [Other templates](#other-templates)
  - [Requirements](#requirements)
  - [How do I use this?](#how-do-i-use-this)
  - [How do I use this template for every Rails app I create?](#how-do-i-use-this-template-for-every-rails-app-i-create)
  - [Contributing](#contributing)
  - [Credits](#credits)

## Background

This template is the set of things we (the Ackama Ruby team) want in **every**
Rails application we create, based on 10+ years of creating new Rails
applications, numerous pen-tests and then maintaining those applications for
years.

Some of these choices are objectively good ideas, some of them are subjective
opinions :shrug:. We are delighted when other teams find this template useful as
either the starting point for their apps, or as the starting point for creating
their own in-house template.

## Features

Where possible we stick to Rails defaults.

- General
  - [puma](https://github.com/puma/puma) as application server
  - [Yarn](https://yarnpkg.com/) for managing JS packages
  - PostgreSQL as database. This template only supports PostgreSQL.
  - A much-improved `bin/setup` script
  - Install [dotenv](https://github.com/bkeepers/dotenv)
  - Create a `doc/` directory for docs
  - Add a middleware to implement HTTP Basic Auth by setting environment
    variables. We use this regularly for pre-production envs.
  - Use [okcomputer](https://github.com/sportngin/okcomputer) for health check
    endpoints. Configured in
    [./config/initializers/health_checks.rb](./config/initializers/health_checks.rb)
  - Install [lograge](https://github.com/roidrage/lograge) for better logs in
    production.
  - Create `app/services` as the place to hold our plain ol' Ruby objects
    wherein we put most of our business logic.
  - Override the default ActiveStorage base controller to force the team to make
    a decision about whether ActiveStorage files must be behind authentication
    or not. The default Rails behaviour here can be a security gotcha.
- Security
  - Install and configure [brakeman](https://github.com/presidentbeef/brakeman)
  - Install and configure
    [bundler-audit](https://github.com/rubysec/bundler-audit)
  - Create `.well-known/security.txt`
  - Add a well documented
    [Content Security Policy initializer](./config/initializers/content_security_policy.rb)
    with secure defaults.
  - Install [pundit](https://github.com/varvet/pundit) as our preferred
    authorization gem
- Error reporting
  - Setup Sentry for error reporting
- Code style
  - Add [EditorConfig](https://editorconfig.org/) config file
    ([.editorconfig](./editorconfig))
  - JS/HTML/CSS: [Prettier](https://prettier.io/), Set up with an
    [Ackama prettier config](https://github.com/ackama/prettier-config-ackama)
    and a variety of other prettier plugins, see the full list in
    [variants/frontend-base/template.rb](./variants/frontend-base/template.rb)
  - JavaScript: [ESlint](https://eslint.org/), Ackama uses the rules found at
    [eslint-config-ackama](https://github.com/ackama/eslint-config-ackama)
    Styles: [stylelint](https://github.com/stylelint/stylelint)
  - Ruby: [Rubocop](https://github.com/rubocop-hq/rubocop), with
    [ackama rubocop settings](./rubocop.yml.tt)
  - Install [Overcommit](https://github.com/sds/overcommit) for managing custom
    git hooks. Configure it with our default settings:
    [overcommit.yml](./overcommit.yml)
- General testing
  - RSpec for tests
  - Install [webdrivers](https://github.com/titusfortner/webdrivers)
  - Install [Simplecov](https://github.com/simplecov-ruby/simplecov) for test
    coverage. Configures it with our defaults.
  - Debug system specs using a visible browser (not headless) by adding
    `HEADFUL=1` environment variable to your command line
- Accessibility testing - sets up automated accessibility testing.
  - Install [axe](https://www.deque.com/axe/) and
    [lighthouse](https://developers.google.com/web/tools/lighthouse) to provide
    comprehensive coverage.
    - Axe Matchers is a gem that provides cucumber steps and rspec matchers that
      will check the accessibility compliance of your views. We require a
      default standard of wcag2a and wcag2aa.
    - We recommend that your tests all live in a `spec/features/accessibility`,
      to allow for running them separately. Using the shared examples found at
      `variants/accessibility/spec/support/shared_examples/an_accessible_page.rb`
      for your base tests avoids duplication and misconfiguration.
  - Install our
    [lighthouse matchers](https://github.com/ackama/lighthouse-matchers) gem
    which provide RSpec matchers to assess the accessibility compliance of your
    application.
    - We recommend setting your passing score threshold to 100 for new projects.
      As with Axe, you can keep your test suite tidy by placing these tests in
      `spec/features/accessibility`.
- Front-end
  - Rename `app/javascript` to `app/frontend`
  - Setup Shakapacker (the maintained fork of Webpacker).
  - > **Note** We are trialing the new JS packaging options that Rails 7+
    > provides. For now our default is still Shakapacker because it provides us
    > the most flexibility.
  - Initializes Ackama's linting and code formatting settings, see
    [Code linting and formatting](#code-linting-and-formatting)
- Performance testing
  - Add configuration and specs to use to perform a
    [lighthouse performance](https://web.dev/performance-scoring/) audit,
    requiring a score of at least 95.
- N+1 queries
  - Install & configure [bullet](https://github.com/flyerhzm/bullet) to help
    prevent N+1 queries
- Devise (optional)
  - Install devise and tweak the configuration. if enabled in the configuration
    file.
  - Configure devise to destroy session cookies on log out (this comes up
    regularly in penetration tests)
- Bootstrap (optional)
  - Installs and configures
    [Bootstrap](https://getbootstrap.com/docs/5.0/getting-started/introduction/)
    if enabled in the configuration file.
- React (optional)
  - Add configuration and example components if enabled in the configuration
    file.
  - Based on [rails-react](https://github.com/reactjs/react-rails)
  - The relevant config files are found in `variants/frontend-react`.
  - An example react test using
    [react-testing-library](https://testing-library.com/docs/react-testing-library/intro/)
    is provided. Before you start adding more tests, it is recommended you read
    [common-mistakes-with-react-testing-library](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- Typescript (optional)
  - Install and configure Typescript including linting
- Sidekiq (optional)
  - Install and configure Sidekiq

## Other templates

Some functionality which isn't something we need on every app is available in
our other templates:

- [Rails template to enable SSL/TLS for local development](https://github.com/ackama/rails-template-ssl-local-dev)
- [Rails template to render PDFs using Puppeteer and Chrome](https://github.com/ackama/rails-template-pdf-rendering)

## Requirements

Before running this template, you must have the following installed on your
machine:

- Yarn v1.21.0 or later
- Rails 7.0.x

The following are not strictly required to run the template but you will need it
to start the Rails app that this template creates:

- [PostgreSQL](https://www.postgresql.org/)
- [Chromedriver](https://chromedriver.chromium.org/)

## How do I use this?

This template requires a YAML configuration file to to configure options. It
will use a file called `ackama_rails_template.config.yml` in your current
working directory if it exists. Otherwise you can specify a path using the
`CONFIG_PATH` environment variable.

[ackama_rails_template.config.yml](./ackama_rails_template.config.yml) is a
documented configuration example that you can copy.

To generate a Rails application using this template, pass the `--template`
option to `rails new`, like this:

```bash
# Ensure you have the latest version of Rails
$ gem install rails

# Example 1
# #########

# Create a config file using the example
$ wget https://raw.githubusercontent.com/ackama/rails-template/main/ackama_rails_template.config.yml

# Tweak the config file as you see fit

# Create a new app using the template. Template options will be taken from
# ./ackama_rails_template.config.yml
$ rails new my_app --no-rc --database=postgresql --skip-javascript --template=https://raw.githubusercontent.com/ackama/rails-template/main/template.rb

# Example 2
# #########

# Create a custom config YAML file, saving as ./my_custom_config.yml

# Template options will be taken from ../my_custom_config.yml (relative to the new app directory)
$ CONFIG_PATH=../my_custom_config.yml rails new my_app --no-rc --database=postgresql --skip-javascript --template=https://raw.githubusercontent.com/ackama/rails-template/main/template.rb
```

Here are some additional options you can add to this command. We don't
_prescribe_ these, but you may find that many Ackama projects are started with
some or all of these options:

- `--skip-action-mailbox` skips the setup of ActionMailbox, which you don't need
  unless you are receiving emails in your application.
- `--skip-active-storage` skips the setup of ActiveStorage. If you don't need
  support for file attachments, this can be skipped.
- `--skip-action-cable` - if you're not doing things with Websockets, you may
  want to consider skipping this one to avoid having an open websocket
  connection without knowing about it.

## How do I use this template for every Rails app I create?

The `rails` command will pull options from a `.railsrc` file in your home
directory. These options will be applied as arguments each time you run
`rails new` (unless you pass the `--no-rc` option).

To make this the default Rails application template on your system, create a
`~/.railsrc` file with these contents:

```
# ~/.railsrc
-d postgresql
--skip-javascript
-m https://raw.githubusercontent.com/ackama/rails-template/main/template.rb
```

Once you've installed this template as your default, then all you have to do is
run:

```bash
$ rails new my-awesome-app
```

## Contributing

This project works by hooking into the standard Rails
[application templates](https://guides.rubyonrails.org/rails_application_templates.html)
system, with some caveats. The entry point is the
[template.rb](https://github.com/ackama/rails-template/blob/main/template.rb)
file in the root of this repository.

Normally, Rails only allows a single file to be specified as an application
template (i.e. using the `-m <URL>` option). To work around this limitation, the
first step this template performs is a `git clone` of the
`ackama/rails-template` repository to a local temporary directory.

This temporary directory is then added to the `source_paths` of the Rails
generator system, allowing all of its ERb templates and files to be referenced
when the application template script is evaluated.

Rails generators are very lightly documented; what you'll find is that most of
the heavy lifting is done by [Thor](http://whatisthor.com/). Thor is a tool that
allows you to easily perform command line utilities. The most common methods
used by this template are Thor's `copy_file`, `template`, and `gsub_file`. You
can dig into the well-organized and well-documented
[Thor source code](https://github.com/erikhuda/thor) to learn more. If any file
finishes with `.tt`, Thor considers it to be a template and places it in the
destination without the extension `.tt`.

```bash
# create new rails app in tmp/builds/enterprise using ci/configs/react.yml as
# configuration
$ CONFIG_PATH="ci/configs/react.yml" APP_NAME="enterprise" ./ci/bin/build-and-test

# or do it manually:
#
# CONFIG_PATH must be relative to the dir that the rails app is created in
# because the template is run by `rails new` which uses the rails app dir as
# it's working dir, hence the `../` at the start.
#
$ rm -rf mydemoapp && CONFIG_PATH="../ci/configs/react.yml" rails new mydemoapp -d postgresql --skip-javascript -m ./template.rb
```

Rubocop is configured for this repo and is run as part of CI. Run rubocop
locally via the usual method:

```
$ bundle install
$ bundle exec rubocop # optionally adding -A for autofixes
```

## Credits

This repo was forked from
[mattbrictson/rails-template](https://github.com/mattbrictson/rails-template)
via [@joshmcarthur](https://github.com/joshmcarthur). Many thanks to
[@mattbrictson](https://github.com/mattbrictson) upon whose foundation we are
building.

Beyond the folks in the contributor graph, the ideas and choices in this
template have been shaped by all the Ackama Ruby team, past and present :heart:.
