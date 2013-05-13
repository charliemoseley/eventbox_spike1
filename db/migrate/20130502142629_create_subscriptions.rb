class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.uuid     :user_id,           null: false
      t.string   :subscribable_type, null: false # must be either Event or Rsvp
      t.uuid     :subscribable_id,   null: false
      t.string   :target,            null: false
      t.hstore   :target_info,       null: false, default: ''
      # this is the account credentials for said provider if required
      t.uuid     :target_account_id

      t.timestamps
    end
    add_index :subscriptions, :target_account_id
    add_index :subscriptions, :user_id
    add_index :subscriptions, [:subscribable_type, :subscribable_id]
    add_index :subscriptions, [:user_id, :subscribable_type, :subscribable_id],
                name: "user_subscribable"
  end
end
