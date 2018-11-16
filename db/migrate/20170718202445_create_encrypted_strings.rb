class CreateEncryptedStrings < ActiveRecord::Migration
  def change
    create_table :encrypted_strings do |t|
      t.string :encrypted_value
      t.string :encrypted_value_iv
      t.string :encrypted_value_salt
      t.belongs_to :data_encrypting_key, index: true, foreign_key: true
      t.string :token, null: false, unique: true, index: true

      t.timestamps null: false
    end
  end
end
