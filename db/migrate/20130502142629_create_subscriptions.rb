class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.uuid     :user_id,           null: false
      t.string   :subscribable_type, null: false # must be either event or rsvp
      t.uuid     :subscribable_id,   null: false
      t.string   :target,            null: false
      t.hstore   :target_info,       null: false, default: ''
      # this is the account credentials for said provider if required
      t.uuid     :account_id # Note, this is the provider's account if they have required credentials
      # the last time for when the update happened, used for resolving conflict
      # resultions
      t.datetime :last_update
      # the date when this event is supposed to happen; used for cleaning out table
      t.datetime :event_date,        null: false

      t.timestamps
    end
    
    add_index :subscriptions, :user_id
    add_index :subscriptions, [:subscribable_type, :subscribable_id], unique: true
    add_index :subscriptions, :account_id
    add_index :subscriptions, :event_date
  end
end
