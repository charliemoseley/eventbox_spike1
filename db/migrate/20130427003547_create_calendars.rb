class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars, id: :uuid do |t|
      t.uuid    :account_id
      t.string  :provider,             null: false
      t.string  :provider_calendar_uid, null: false
      t.string  :purpose,              null: false
      t.string  :etag
      t.text    :raw,                  null: false
      
      t.timestamps
    end
    
    add_index :calendars, [:account_id, :provider]
    add_index :calendars, [:provider, :provider_calendar_uid], unique: true
  end
end
