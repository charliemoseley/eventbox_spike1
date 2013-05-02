class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string  :provider,    null: false
      t.string  :provider_id, null: false
      t.text    :raw,         null: false
      t.string  :digest,      null: false
      
      t.timestamps
    end
    add_index :events, [:provider, :provider_id], unique: true
    add_index :events, :digest, unique: true

    create_table :event_rsvps do |t|
      t.integer :user_id,  null: false
      t.integer :event_id, null: false
      t.string  :status,   null: false
      t.string  :extra
    end
    add_index :event_rsvps, :user_id
    add_index :event_rsvps, :event_id
  end
end