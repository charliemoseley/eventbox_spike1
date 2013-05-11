web: bundle exec puma -t 0:4 -p $PORT -e $RACK_ENV
worker: bundle exec sidekiq -c 14 -r ./config/workers.rb
pubsub: bundle exec ruby pubsub.rb