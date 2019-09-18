# Pull from the latest Ruby version
# We don't use slim or alpine variants as we invariably need build tooling, which
# the base image includes for us.
FROM ruby

# Avoid issues with file encoding in Ruby by setting these two environment variables
# This tells the underlying OS to expect en_US-UTF-8 encoding (e.g. UTF-8 encoding in the US language)
ENV LANG "C"
ENV LC_ALL en_US.UTF-8


# Curl is installed to make it possible to set up PPAs below - it is
# removed further down.
RUN apt-get update -qq &&\
    apt-get install -y curl 

# Install Node.js PPA for asset management
# As of writing, Node 10 is the most recent LTS.
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash &&\
    apt-get update -qq && apt-get install -y nodejs

# Install Google Chrome. Chrome is required for headless system tests.
RUN curl -q https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable --no-install-recommends

# Install system dependencies, and remove curl now that we have PPAs set up
RUN apt-get update -qq &&\
    apt-get install google-chrome libpq-dev nodejs --no-install-recommends &&\
    apt-get purge -y curl &&
    rm -rf /var/lib/apt/lists/*

# Create a directory to hold application code
# We do this at this point so we can set this as the home directory of
# the 'deploy' user.
RUN mkdir /usr/src/app

# Create a non-privileged deploy user, and add all application code as this user.
RUN adduser --disabled-password --gecos "" deploy && chown -R deploy:deploy /usr/src/app
USER deploy

# Add all application code to /usr/src/app and set this as the working directory
# of the container
ADD . /usr/src/app
WORKDIR /usr/src/app

# Install gem and NPM dependencies. These are baked into the image so the image can run
# standalone provided valid configuration. When running in docker-compose, these 
# dependencies are stored in a volume so the image does not need rebuilding when the
# dependencies are changed.
RUN bundle install
RUN npm ci

# Default command is to start a Puma server
CMD bundle exec rails server --binding=0.0.0.0
