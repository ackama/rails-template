insert_into_file "config/environments/production.rb",
                 after: /# config\.assets\.css_compressor = :sass\n/ do
  <<-RUBY

  # Disable minification since it adds a *huge* amount of time to precompile.
  # Anyway, gzip alone gets us about 70% of the benefits of minify+gzip.
  config.assets.css_compressor = false
  RUBY
end

gsub_file! "config/environments/production.rb",
           "# config.force_ssl = true",
           <<~RUBY
             ##
             # `force_ssl` defaults to on. Set `force_ssl` to false if (and only if) RAILS_FORCE_SSL=false, otherwise set it to true.
             #
             config.force_ssl = ENV.fetch("RAILS_FORCE_SSL", "true").downcase != "false"
           RUBY

insert_into_file "config/environments/production.rb",
                 after: /# config\.action_mailer\.raise_deliv.*\n/ do
  <<-RUBY

  # Production email config
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = {
    host: "#{TEMPLATE_CONFIG.production_hostname}",
    protocol: "https"
  }
  config.action_mailer.asset_host = "https://#{TEMPLATE_CONFIG.production_hostname}"

  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_HOSTNAME"),
    port: ENV.fetch("SMTP_PORT", 587),
    enable_starttls_auto: true,
    user_name: ENV.fetch("SMTP_USERNAME"),
    password: ENV.fetch("SMTP_PASSWORD"),
    authentication: "login",
    domain: "#{TEMPLATE_CONFIG.production_hostname}"
  }

  RUBY
end

gsub_file! "config/environments/production.rb",
           "config.log_level = :info",
           'config.log_level = ENV.fetch("LOG_LEVEL", "info").to_sym'

gsub_file! "config/environments/production.rb",
           "ActiveSupport::Logger.new(STDOUT)",
           "ActiveSupport::Logger.new($stdout)"

insert_into_file "config/environments/production.rb",
                 after: /.*config\.public_file_server\.enabled.*\n/ do
  <<~'RUBY'

    # Ensure that Rails sets appropriate caching headers on static assets if
    # Rails is serving static assets in production e.g. on Heroku
    #
    # Overview of Cache-control values:
    #
    #     max-age=<seconds>
    #         The maximum amount of time a resource is considered fresh.
    #
    #     s-maxage=<seconds>
    #         Overrides max-age or the Expires header, but only for shared
    #         caches (e.g., proxies). Ignored by private caches.
    #
    #     More info: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
    #
    # Our Cache-Control header:
    #
    # * It tells all caches (both proxies like Cloudflare and the users web
    #   browser) that the asset can be cached.
    # * It tells shared caches (e.g. Cloudflare) that they can cache it for 365 days
    # * It tells browsers that they should cache for 365 days
    #
    # Cloudflare will respect s-maxage if it is set so change that value if you
    # want Cloudflare to cache differently than then browser.
    #
    config.public_file_server.headers = {
      "Cache-Control" => "public, s-maxage=#{365.days.seconds}, max-age=#{365.days.seconds}"
    }

  RUBY
end

insert_into_file "config/environments/production.rb",
                 after: /.*config.cache_store = :mem_cache_store\n/ do
  <<~RUBY
    if ENV.fetch("RAILS_CACHE_REDIS_URL", nil)
      config.cache_store = :redis_cache_store, {
        url: ENV.fetch("RAILS_CACHE_REDIS_URL"),
        ##
        # Configuring a connection pool for Redis as Rails cache is documented in:
        #
        # * https://edgeguides.rubyonrails.org/caching_with_rails.html#connection-pool-options
        #
        # but some more details are available in:
        #
        # * https://github.com/rails/rails/blob/a5d1628c79ab89dfae57ec1e1aeca467e29de188/activesupport/lib/active_support/cache.rb#L168-L173
        # * https://github.com/rails/rails/blob/9b4aef4be3dc58eb08f694387857b52be8050954/activesupport/lib/active_support/cache/redis_cache_store.rb#L185-L192
        #
        pool_size: Integer(ENV.fetch("RAILS_MAX_THREADS", 5)), # number of connections **per puma process**
        pool_timeout: 5 # num seconds to wait for a connection
      }
    end
  RUBY
end
