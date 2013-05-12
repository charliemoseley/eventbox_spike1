class FixIndexs < ActiveRecord::Migration
  def change
    # This removes the unique index version
    remove_index :subscriptions, [:subscribable_type, :subscribable_id]
    add_index    :subscriptions, [:subscribable_type, :subscribable_id]
    add_index    :subscriptions, [:user_id, :subscribable_type, :subscribable_id],
                   name: "user_subscribable"
  end
end
