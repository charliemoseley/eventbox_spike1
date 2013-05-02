class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.integer :user_id
      t.integer :account_id
      t.string  :provider,    null: false
      t.string  :calendar_id, null: false
      t.string  :purpose,     null: false
      t.string  :etag
      t.text    :raw,         null: false
      
      t.timestamps
    end
    add_index :calendars, :calendar_id, unique: true
    add_index :calendars, :user_id
    add_index :calendars, :account_id
  end
end
