class CreateUsers < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    enable_extension 'hstore'

    create_table :users, id: :uuid do |t|
      t.string  :name
      t.string  :first_name
      t.string  :last_name
      t.string  :email, null: false
      t.string  :image
      t.boolean :active, null: false, default: false
      
      t.timestamps
    end
    
    add_index :users, :email, unique: true
  end
end
