web:     bundle exec puma -C config/puma.rb
worker:  bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rake db:migrate db:seed
