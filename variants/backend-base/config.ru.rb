insert_into_file "config.ru", before: /^run Rails.application/ do
  <<~RUBY
    use Rack::CanonicalHost, ENV["CANONICAL_HOSTNAME"] if ENV["CANONICAL_HOSTNAME"].present?
  RUBY
end
