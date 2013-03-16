require 'sidekiq'
require 'redis'

class Workers
  $redis = Redis.connect
  
  class SinatraWorker
    include Sidekiq::Worker

    def perform(msg="lulz you forgot a msg!")
      $redis.lpush("sinkiq-example-messages", msg)
    end
  end
end