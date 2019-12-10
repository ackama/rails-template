# Rails Template

## Origins

This repo is forked from mattbrictson/rails-template, and has been customized to
set up Rails projects the way I like them.

## Description

This is the application template that I use for my Rails 6 projects. As a
freelance Rails developer, I need to be able to start new projects quickly and
with a good set of defaults. I've assembled this template over the years to
include best-practices, tweaks, documentation, and personal preferences, while
still generally adhering to the "Rails way".

For older versions of Rails, use these branches:

- [Rails 4.2.x](https://github.com/mattbrictson/rails-template/tree/rails-42)
- [Rails 5.0.x](https://github.com/mattbrictson/rails-template/tree/rails-50)
- [Rails 5.1.x](https://github.com/mattbrictson/rails-template/tree/rails-51)
- [Rails 5.2.x](https://github.com/mattbrictson/rails-template/tree/rails-52)

## Requirements
 
- Yarn: Some old versions of Yarn have encountered issues, if you have problems try v1.21.0 or later

This template currently works with:

- Rails 6.0.x
- PostgreSQL
- chromedriver

## Installation

_Optional._

To make this the default Rails application template on your system, create a
`~/.railsrc` file with these contents:

```
-d postgresql
-m https://raw.githubusercontent.com/ackama/rails-template/master/template.rb
```

## Usage

This template assumes you will store your project in a remote git repository
(e.g. Bitbucket or GitHub) and that you will deploy to a production environment.
It will prompt you for this information in order to pre-configure your app, so
be ready to provide:

1. The git URL of your (freshly created and empty) Bitbucket/GitHub repository
2. The hostname of your production server

To generate a Rails application using this template, pass the `-m` option to
`rails new`, like this:

```
rails new blog \
  -d postgresql \
  -m https://raw.githubusercontent.com/ackama/rails-template/master/template.rb
```

_Remember that options must go after the name of the application._ The only
database supported by this template is `postgresql`.

If you’ve installed this template as your default (using `~/.railsrc` as
described above), then all you have to do is run:

```
rails new blog
```

If you just want to see what the template does, try running `docker build .` and
then `docker --rm -it run` the resulting image. You'll be dropped into Bash and
can explore the generated app in `/apps/template-test`. The image doesn't
include PostgreSQL right now, so database operations don't work.

## What does it do?

The template will perform the following steps:

1. Generate your application files and directories
2. Ensure bundler is installed
3. Create the development and test databases
4. Commit everything to git
5. Push the project to the remote git repository you specified

## What is included?

#### These gems are added to the standard Rails stack

- Core
  - `puma` - application web server used for all environments
  - [sidekiq][] – Redis-based job queue implementation for Active Job
- Configuration
  - [dotenv][] – in place of the Rails `secrets.yml`
- Utilities
  - [rubocop][] – enforces Ruby code style
- Security
  - [brakeman][] and [bundler-audit][] – detect security vulnerabilities
- Testing
  - [simplecov][] – code coverage reports
  - `webdrivers` - auto-installs headless Chrome

#### Other tweaks that patch over some Rails shortcomings

- A much-improved `bin/setup` script

## How does it work?

This project works by hooking into the standard Rails [application templates][]
system, with some caveats. The entry point is the [template.rb][] file in the
root of this repository.

Normally, Rails only allows a single file to be specified as an application
template (i.e. using the `-m <URL>` option). To work around this limitation, the
first step this template performs is a `git clone` of the
`ackama/rails-template` repository to a local temporary directory.

This temporary directory is then added to the `source_paths` of the Rails
generator system, allowing all of its ERb templates and files to be referenced
when the application template script is evaluated.

Rails generators are very lightly documented; what you’ll find is that most of
the heavy lifting is done by [Thor][]. The most common methods used by this
template are Thor’s `copy_file`, `template`, and `gsub_file`. You can dig into
the well-organized and well-documented [Thor source code][thor] to learn more.
