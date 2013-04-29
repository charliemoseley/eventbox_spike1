web: bundle exec puma -p $PORT -e $RACK_ENV
worker: bundle exec sidekiq -r ./config/workers.rb