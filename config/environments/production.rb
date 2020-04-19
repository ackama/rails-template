insert_into_file "config/environments/production.rb",
                 after: /# config\.assets\.css_compressor = :sass\n/ do
  <<-RUBY

  # Disable minification since it adds a *huge* amount of time to precompile.
  # Anyway, gzip alone gets us about 70% of the benefits of minify+gzip.
  config.assets.css_compressor = false
  RUBY
end

uncomment_lines "config/environments/production.rb", /config\.force_ssl = true/
gsub_file "config/environments/production.rb",
          "config.force_ssl = true",
          'config.force_ssl = ENV["RAILS_FORCE_SSL"].present?'

insert_into_file "config/environments/production.rb",
                 after: /# config\.action_mailer\.raise_deliv.*\n/ do
  <<-RUBY

  # Production email config
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = {
    host: "#{production_hostname}",
    protocol: "https"
  }
  config.action_mailer.asset_host = "https://#{production_hostname}"
  RUBY
end

gsub_file "config/environments/production.rb",
          "config.log_level = :debug",
          'config.log_level = ENV.fetch("LOG_LEVEL", "info").to_sym'

insert_into_file "config/environments/production.rb",
  after: /.*config\.public_file_server\.enabled.*\n/ do
  <<~'RUBY'

    # Ensure that Rails sets appropriate caching headers on static assets if
    # Rails is serving static assets in production e.g. on Heroku
    #
    # | Seconds  | Days     |
    # |----------|----------|
    # | 86400    | 1 day    |
    # | 15552000 | 180 days |
    # | 31536000 | 365 days |
    #
    # Overview of Cache-control values:
    #
    #     max-age=<seconds>
    #         The maximum amount of time a resource is considered fresh. Unlike
    #         Expires, this directive is relative to the time of the request.
    #
    #     s-maxage=<seconds>
    #         Overrides max-age or the Expires header, but only for shared
    #         caches (e.g., proxies). Ignored by private caches.
    #
    #     More info: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
    #
    # Our Cache-Control header:
    #
    # * It tells all caches (both proxies like Cloudflare and the users web browser) that the asset can be cached.
    # * It tells shared caches (e.g. Cloudflare) that they can cache it for 365 days
    # * It tells browsers that they should cache for 365 days
    #
    # Cloudflare will respect s-maxage if it is set so change that value if you
    # want Cloudflare to cache differently than then browser.
    #
    config.public_file_server.headers = {
      "Cache-Control" => "public, s-maxage=31536000, max-age=31536000",
      "Expires" => "#{1.year.from_now.to_formatted_s(:rfc822)}"
    }

  RUBY
end
