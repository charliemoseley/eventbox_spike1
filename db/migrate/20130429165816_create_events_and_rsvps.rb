class CreateEventsAndRsvps < ActiveRecord::Migration
  def change
    create_table :events, id: :uuid do |t|
      t.string   :provider,     null: false
      t.string   :external_uid, null: false
      t.string   :title
      t.text     :description
      t.string   :url
      t.string   :address
      t.datetime :start_time
      t.datetime :end_time
      t.text     :raw,          null: false
      t.string   :digest,       null: false
      
      t.timestamps
    end
    add_index :events, [:provider, :provider_source_uid], unique: true
    add_index :events, :digest, unique: true

    create_table :rsvps, id: :uuid do |t|
      t.string   :status, null: false
      t.string   :raw,    null: false

      t.timestamps
    end
  end
end