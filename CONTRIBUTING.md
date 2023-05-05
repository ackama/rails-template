# Contributing

Although we are always happy to make improvements, we also welcome changes and
improvements from the community!

Have a fix for a problem you've been running into or an idea for a new feature
you think would be useful? Here's what you need to do:

1. [Read and understand the Code of Conduct](#code-of-conduct).
2. Fork this repo (unless you work at Ackama) and clone that repo to somewhere
   on your machine.
3. [Ensure that you have a working environment](#setting-up-your-environment).
4. Read up on the [architecture of the project](#architecture),
   [how to run tests](#tests), and
   [the code style we use in this project](#code-style).
5. Cut a new branch and write a failing test for the feature or bugfix you plan
   on implementing.
6. [Make sure your branch is well managed as you go along](#managing-your-branch).
7. If this branch fixes an issue, use github's `fixes: #issue_number` when
   writing your commit message to link the issue to your pr.
8. Push to your fork and create a pull request.
9. Ensure that the test suite passes CI and make any necessary changes to your
   branch to bring it to green.

We aim to review pull requests at our internal Ackama fortnightly ruby guild
meeting. Once we look at your pull request, we may give you feedback. For
instance, we may suggest some changes to make to your code to fit within the
project style or discuss alternate ways of addressing the issue in question.
Assuming we're happy with everything, we'll then bring your changes into main.
Now you're a contributor!

## Code of Conduct

If this is your first time contributing, please read the [Code of Conduct]. We
want to create a space in which everyone is allowed to contribute, and we
enforce the policies outline in this document.

[code of conduct]:
  https://github.com/ackama/rails-template/blob/main/CODE_OF_CONDUCT.md

## Setting up your environment

1. Install
   [the most recent ruby version](https://www.ruby-lang.org/en/downloads/) with
   the ruby version manager of your choice
2. Run `gem install rails` to get the most recent rails release
3. Install the node version defined in the `.node-version` file with the node
   version manager of your choice
4. Install yarn v1

To run tests you'll also need to install

- [PostgreSQL](https://www.postgresql.org/)
- [Chromedriver](https://chromedriver.chromium.org/)

## Architecture

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

## Tests

this template is tested by building a set of apps with different configuration
and checking each passes the templated linters and tests.

the config is in ci/configs/\*.yml, and is run by ci/bin/build-and-test

```bash
# create new rails app in tmp/builds/enterprise using ci/configs/react.yml as
$ CONFIG_PATH="ci/configs/react.yml" APP_NAME="enterprise" ./ci/bin/build-and-test
```

To add another tested configuration

1. add a file in ci/configs
2. add it to the lists in .github/workflows/ci.yml

## Code style

Rubocop is configured for this repo and is run as part of CI. Run rubocop
locally via the usual method:

```
$ bundle install
$ bundle exec rubocop # optionally adding -a or -A for autofixes
```

Prettier is used to manage the style for json, js/jsx/ts/tsx, css/scss, and
md/markdown files, and is run as part of CI. Run prettier localy via yarn

```
$ yarn install
$ yarn run format-check # or `yarn run format-fix` for autofixes
```

## Managing your branch

- Use well-crafted commit messages, providing context if possible.
- Squash "WIP" commits and remove merge commits by rebasing your branch against
  `main`. We try to keep our commit history as clean as possible.

## Documentation

As you navigate the codebase, you may notice certain classes and methods that
are prefaced with inline documentation.

If your changes end up extending or updating the API, it helps greatly to update
the docs at the same time for future developers and other readers of the source
code.

Ensure any changes to features documented in the README.md or this
CONTRIBUTING.md have their documentation updated as necessary.

If you're ackama staff, ensure any linked ackama-internal documentation is also
up-to-date.
