# web: bundle exec puma -p $PORT -e $RACK_ENV
web: bundle exec rackup
worker: bundle exec sidekiq -r ./workers/boot.rb