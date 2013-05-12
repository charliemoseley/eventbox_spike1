class Subscription < ActiveRecord::Base
  belongs_to :subscribable, polymorphic: true
  belongs_to :user
  belongs_to :account

  def update(time)
    target = self.target.capitalize
    class_name = "Subscription#{self.subscribable_type.capitalize}"
    if worker_exists?(target, class_name) 
      klass = Kernel.const_get("Worker").const_get(target).const_get(class_name)
      klass.perform_async(self.id, time)
    else
      puts "ERROR: Worker::#{target}::#{class_name} doesn't exist [models/subscription]"
    end
  end

  def self.update_individual(id, time)
    subscription = Subscription.find id
    subscription.update(time)
  end

  private

  def worker_exists?(target, class_name)
    klass = Module.const_get("Worker").const_get(target).const_get(class_name) rescue nil
    return klass.is_a?(Class)
  rescue NameError
    return false
  end
end