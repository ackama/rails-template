Rails.application.configure do
  # lograge can be customised to add custom values to logs, ignore certain
  # controllers etc. Full instructions at https://github.com/roidrage/lograge
  config.lograge.enabled = true unless Rails.env.development? || Rails.env.test?
end
