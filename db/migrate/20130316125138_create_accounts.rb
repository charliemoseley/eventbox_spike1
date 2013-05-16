class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts, id: :uuid do |t|
      t.uuid    :user_id
      t.string  :provider,     null: false
      t.string  :provider_uid, null: false
      t.string  :name
      t.string  :email
      t.string  :first_name
      t.string  :last_name
      t.string  :image
      t.string  :token,        null: false
      t.string  :refresh_token
      t.text    :raw,          null: false
      t.boolean :active,       null: false, default: :true
      
      t.timestamps
    end
    
    add_index :accounts, :user_id
    add_index :accounts, [:provider, :provider_uid], unique: true
  end
end