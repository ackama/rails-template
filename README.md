# Ackama Rails Template

This is the application template that we use for new Rails projects. As a
fabulous consultancy, we need to be able to start new projects quickly and with
a good set of defaults.

This template bakes in the gems and configuration choices that we want to have
on **all** of our Rails apps. Some of these choices are based on years of
creating Rails apps and feedback from multiple pen-tests and security reviews.
Some of these choices are just our preferences :shrug:.

- [Ackama Rails Template](#ackama-rails-template)
  - [What does this template provide me?](#what-does-this-template-provide-me)
    - [Standard Rails stuff](#standard-rails-stuff)
    - [General](#general)
    - [Security](#security)
    - [Error reporting](#error-reporting)
    - [Code style](#code-style)
    - [General testing](#general-testing)
    - [Accessibility testing](#accessibility-testing)
    - [Front-end](#front-end)
    - [Performance testing](#performance-testing)
    - [N+1 queries](#n1-queries)
    - [Devise (optional)](#devise-optional)
    - [Bootstrap (optional)](#bootstrap-optional)
    - [React (optional)](#react-optional)
    - [Sidekiq (optional)](#sidekiq-optional)
  - [Requirements](#requirements)
  - [Usage](#usage)
  - [Installation (Optional)](#installation-optional)
  - [Contributing to this template](#contributing-to-this-template)
  - [Origins](#origins)

## What does this template provide me?

Our starting point is a vanilla Rails 7 install.

### Standard Rails stuff

- Use [puma](https://github.com/puma/puma) as application server
- Use [Yarn](https://yarnpkg.com/) for managing JS packages

### General

- A much-improved `bin/setup` script
- Install [dotenv](https://github.com/bkeepers/dotenv)
- We use PostgreSQL because it's great

### Security

- Install and configure [brakeman](https://github.com/presidentbeef/brakeman)
- Install and configure
  [bundler-audit](https://github.com/rubysec/bundler-audit)

### Error reporting

- Setup Sentry for error reporting

### Code style

- Add [EditorConfig](https://editorconfig.org/) config file
  ([.editorconfig](./editorconfig))
- JS/HTML/CSS: [Prettier](https://prettier.io/), Set up with an
  [Ackama prettier config](https://github.com/ackama/prettier-config-ackama) and
  a variety of other prettier plugins, see the full list in
  `variants/frontend-base/template.rb`
- JavaScript: [ESlint](https://eslint.org/), Ackama uses the rules found at
  [eslint-config-ackama](https://github.com/ackama/eslint-config-ackama) Styles:
  [stylelint](https://github.com/stylelint/stylelint)
- Ruby: [Rubocop](https://github.com/rubocop-hq/rubocop), with
  [ackama rubocop settings](https://bitbucket.org/rabidtech/rabid-dotfiles/raw/master/.rubocop.yml)
- Install [Overcommit](https://github.com/sds/overcommit) for managing custom
  git hooks. Configure it with our default settings
  ([overcommit.yml](./overcommit.yml)

### General testing

- Install [webdrivers](https://github.com/titusfortner/webdrivers)
- Install [Simplecov](https://github.com/simplecov-ruby/simplecov) for test
  coverage. Configures it with our defaults.

### Accessibility testing

Sets up automated accessibility testing.

- Install [axe](https://www.deque.com/axe/) and
  [lighthouse](https://developers.google.com/web/tools/lighthouse) to provide
  comprehensive coverage.
  - Axe Matchers is a gem that provides cucumber steps and rspec matchers that
    will check the accessibility compliance of your views. We require a default
    standard of wcag2a and wcag2aa.
  - We recommend that your tests all live in a `spec/features/accessibility`, to
    allow for running them separately. Using the shared examples found at
    `variants/accessibility/spec/support/shared_examples/an_accessible_page.rb`
    for your base tests avoids duplication and misconfiguration.
- Install our
  [lighthouse matchers](https://github.com/ackama/lighthouse-matchers) gem which
  provide RSpec matchers to assess the accessibility compliance of your
  application.
  - We recommend setting your passing score threshold to 100 for new projects.
    As with Axe, you can keep your test suite tidy by placing these tests in
    `spec/features/accessibility`.

### Front-end

> **Note** We are trialing the new JS packaging options that Rails 7+ provides.
> For now our default is still Webpacker because it provides us the most
> flexibility.

- rename `app/javascript` to `app/frontend`
- Setup Webpacker.
- Initializes [sentry](https://sentry.io/welcome/) JS for error reporting
- Initializes Ackama's linting and code formatting settings, see
  [Code linting and formatting](#code-linting-and-formatting)

### Performance testing

Add configuration and specs to use to perform a
[lighthouse performance](https://web.dev/performance-scoring/) audit, requiring
a score of at least 95.

### N+1 queries

Add configuration to use to prevent N+1 queries, see
[bullet](https://github.com/flyerhzm/bullet)

### Devise (optional)

Install devise and tweak the configuration. if enabled in the configuration
file.

### Bootstrap (optional)

Installs and configures
[Bootstrap](https://getbootstrap.com/docs/5.0/getting-started/introduction/) if
enabled in the configuration file.

### React (optional)

- Add configuration and example componenents if enabled in the configuration
  file.
- Based on [rails-react](https://github.com/reactjs/react-rails)
- The relevant config files are found in `variants/frontend-react`.
- An example react test using
  [react-testing-library](https://testing-library.com/docs/react-testing-library/intro/)
  is provided. Before you start adding more tests, it is recommended you read
  [common-mistakes-with-react-testing-library](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

### Sidekiq (optional)

A job scheduler is a computer application for controlling unattended background
program execution of jobs

## Requirements

Before running this template, you must have the following installed on your
machine:

- Yarn v1.21.0 or later
- Rails 7.0.x

The following are not strictly required to run the template but you will need it
to start the Rails app that this template creates:

- PostgreSQL
- chromedriver

## Usage

This template requires a YAML configuration file to to configure options.

It will use `ackama_rails_template.config.yml` in your current working directory
if it exists. Otherwise you can specify a path using the `CONFIG_PATH`
environment variable.

[ackama_rails_template.config.yml](./ackama_rails_template.config.yml) is a
documented configuration example that you can copy.

To generate a Rails application using this template, pass the `--template`
option to `rails new`, like this:

```bash
# template options will be taken from ./ackama_rails_template.config.yml
$ rails new my_app --no-rc --database=postgresql --skip-javascript --template=https://raw.githubusercontent.com/ackama/rails-template/main/template.rb

# template options will be taken from from your custom config file
$ CONFIG_PATH=./my_custom_config.yml rails new my_app --no-rc --database=postgresql --skip-javascript --template=https://raw.githubusercontent.com/ackama/rails-template/main/template.rb
```

The only database supported by this template is `postgresql`.

Here are some additional options you can add to this command. We don't
_prescribe_ these, but you may find that many Ackama projects are started with
some or all of these options:

- `--skip-javascript` skips the setup of JavaScript imports/compilers, Rails
  7.0.x is no longer automatically includes
  [Webpacker](https://github.com/rails/webpacker), instead it uses
  [Importmap](https://github.com/rails/importmap-rails) by default.
- `--skip-action-mailbox` skips the setup of ActionMailbox, which you don't need
  unless you are receiving emails in your application.
- `--skip-active-storage` skips the setup of ActiveStorage. If you don't need
  support for file attachments, this can be skipped.
- `--skip-action-cable` - if you're not doing things with websockets, you may
  want to consider skipping this one to avoid having an open websocket
  connection without knowing about it.
- `--webpack=react` - this will preconfigure your app to build and serve React
  code. You only need it if you're going to be using React, but adding this
  during app generation will mean that your codebase supports webpack and React
  components right from the first commit.

## Installation (Optional)

If you find yourself generating a lot of Rails applications, you can load
default options into a file in your home directory named `.railsrc`, and these
options will be applied as arguments each time you run `rails new` (unless you
pass the `--no-rc` option).

To make this the default Rails application template on your system, create a
`~/.railsrc` file with these contents:

```
# ~/.railsrc
-d postgresql
-m https://raw.githubusercontent.com/ackama/rails-template/main/template.rb
```

Once you've installed this template as your default, then all you have to do is
run:

```bash
$ rails new my-awesome-app
```

## Contributing to this template

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
# create new rails app in tmp/builds/enterprise using ci/configs/react.yml as configuration
CONFIG_PATH="ci/configs/react.yml" APP_NAME="enterprise" ./ci/bin/build-and-test

# or do it manually:
#
# CONFIG_PATH must be relative to the dir that the rails app is created in
# because the template is run by `rails new` which uses the rails app dir as
# it's working dir, hence the `../` at the start.
#
rm -rf mydemoapp && CONFIG_PATH="../ci/configs/react.yml" rails new mydemoapp -d postgresql --skip-javascript -m ./template.rb
```

## Origins

This repo is forked from
[mattbrictson/rails-template](https://github.com/mattbrictson/rails-template),
and has been customized to set up Rails projects the way Ackama likes them. Many
thanks to [@joshmcarthur](https://github.com/joshmcarthur) and
[@mattbrictson](https://github.com/mattbrictson) upon whose work we have built.
