class Subscription < ActiveRecord::Base
  belongs_to :subscribable, polymorphic: true
  belongs_to :user
  belongs_to :account

  def update(time)
    klass = "Worker::#{subscriber.capitalize}::Subscription#{subscribable_type.capitalize}"
    if class_exists?(klass) 
      Kernel.const_get(klass).perfom(id, time)
    end
  end

  private

  def class_exists?(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
  rescue NameError
    return false
  end
end