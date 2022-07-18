# Pull from the latest Ruby version
# We don't use slim or alpine variants as we invariably need build tooling, which
# the base image includes for us.
FROM ruby

# Avoid issues with file encoding in Ruby by setting these two environment variables
# This tells the underlying OS to expect UTF-8 encoding (e.g. UTF-8 encoding in the US language)
ENV LANG=C \
    LC_ALL=C.UTF-8 \
    PORT=3000


# Curl is installed to make it possible to set up PPAs below - it is
# removed further down.
RUN apt-get update -qq &&\
    apt-get install -y curl

# Install Node.js PPA for asset management
# As of writing, Node 10 is the most recent LTS.
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash

# Install Google Chrome PPA. Chrome is required for headless system tests.
RUN curl -q https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# Install system dependencies, and remove curl now that we have PPAs set up
# We also clean out system files we don't need to reduce image size:
#   * /usr/share/man - manual pages
#   * /usr/share/locales - we don't need to support multiple languages at the OS level
#   * /var/cache/apt/archives - we don't need to hold onto deb packages once they're installed
RUN apt-get update -qq &&\
    apt-get upgrade -y &&\
    apt-get install -y google-chrome-stable libpq-dev nodejs --no-install-recommends &&\
    apt-get purge -y curl &&\
    apt-get autoremove -y &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/* \
           /usr/share/man \
           /usr/share/locales \
           /var/cache/apt/archives

# Use NPM to install Yarn.
RUN npm install -g yarn

# Install gem and NPM dependencies. These are baked into the image so the image can run
# standalone provided valid configuration. When running in docker-compose, these
# dependencies are stored in a volume so the image does not need rebuilding when the
# dependencies are changed.
RUN mkdir -p /usr/src/app/node_modules

# Create a non-privileged deploy user, and add all application code as this user.
RUN adduser --disabled-password --gecos "" deploy && chown -R deploy:deploy /usr/src/app
VOLUME /usr/src/app/node_modules
VOLUME /usr/local/bundle
USER deploy

# Add just the dependency manifests before installing.
# This reduces the chance that bundler or NPM will get a cold cache because some kind of application file changed.
ADD Gemfile* package.json yarn.lock /usr/src/app/
WORKDIR /usr/src/app
RUN bundle check || bundle install &&\
    yarn install --frozen-lockfile

# Add all application code to /usr/src/app and set this as the working directory
# of the container
ADD . /usr/src/app

EXPOSE $PORT

# Default command is to start a Puma server
CMD bundle exec rails server --binding=0.0.0.0
