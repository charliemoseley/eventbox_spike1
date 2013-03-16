class Workers
  class Message
    class Test
      include Sidekiq::Worker

      def perform(msg="lulz you forgot a msg!")
        $redis.lpush("sinkiq-example-messages", msg)
      end
    end
  end
end