class CreateUsers < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'

    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.string :image
      
      t.timestamps
    end
    
    add_index :users, :email, unique: true
  end

  def down
    drop_table :users
  end
end
