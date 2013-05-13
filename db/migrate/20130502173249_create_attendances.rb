class CreateArchives < ActiveRecord::Migration
  def change
    create_table :attendances, id: :uuid do |t|
      t.uuid :user_id,  null: false
      t.uuid :event_id, null: false
      t.uuid :rsvp_id,  null: false

      t.timestamps
    end

    add_index :attendances, :user_id
    add_index :attendances, [:user_id, :event_id], unique: true
    add_index :attendances, [:user_id, :rsvp_id],  unique: true
  end
end