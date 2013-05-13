class CreateEventsAndRsvps < ActiveRecord::Migration
  def change
    create_table :events, id: :uuid do |t|
      t.string   :provider,     null: false
      t.string   :external_uid, null: false
      t.string   :title,        null: false
      t.text     :description
      t.string   :address
      t.string   :url
      # This is going to be either open, full, or waitlisted
      t.string   :status,       null: false
      t.datetime :start_time,   null: false
      t.datetime :end_time,     null: false
      t.text     :raw,          null: false
      t.string   :digest,       null: false
      
      t.timestamps
    end
    add_index :events, [:provider, :external_uid], unique: true
    add_index :events, :digest, unique: true

    create_table :rsvps, id: :uuid do |t|
      t.string   :status, null: false
      t.string   :raw,    null: false

      t.timestamps
    end
  end
end