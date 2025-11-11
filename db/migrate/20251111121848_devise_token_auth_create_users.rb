class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[7.0]
  def change
    
    add_column :users, :provider, :string, null: false, default: "email"
    add_column :users, :uid, :string, null: false, default: ""
    
    # For the password change feature
    add_column :users, :allow_password_change, :boolean, default: false

    # For confirmable fields
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string

    # User info
    add_column :users, :name, :string
    add_column :users, :nickname, :string
    add_column :users, :image, :string

    # Tokens (used for token authentication)
    add_column :users, :tokens, :json

    # Add indexes for the new fields
    add_index :users, :confirmation_token, unique: true
    add_index :users, [:uid, :provider], unique: true
  end
end
