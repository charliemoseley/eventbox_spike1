class CreateEventsAndRsvps < ActiveRecord::Migration
  def change
    create_table :events, id: :uuid do |t|
      t.string   :provider,           null: false
      t.string   :provider_source_id, null: false
      t.text     :raw,                null: false
      t.string   :digest,             null: false
      t.datetime :last_update
      
      t.timestamps
    end
    add_index :events, [:provider, :provider_id], unique: true
    add_index :events, :digest, unique: true

    create_table :rsvps, id: :uuid do |t|
      t.string   :status,     null: false
      t.string   :extra,
      t.datetime :last_update

      t.timestamps
    end
  end
end