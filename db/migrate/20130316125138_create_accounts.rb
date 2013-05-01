class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :user_id
      t.string  :provider, null: false
      t.string  :uid, null: false
      t.string  :name
      t.string  :email
      t.string  :first_name
      t.string  :last_name
      t.string  :image
      t.string  :token, null: false
      t.string  :refresh_token
      t.integer :expires_at
      t.boolean :expires
      t.text    :raw, null: false
      
      t.timestamps
    end
    
    add_index :accounts, [:provider, :uid], unique: true
    add_index :accounts, :refresh_token
    add_index :accounts, :user_id
  end
end