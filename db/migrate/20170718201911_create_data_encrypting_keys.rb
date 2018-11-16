class CreateDataEncryptingKeys < ActiveRecord::Migration
  def change
    create_table :data_encrypting_keys do |t|
      t.string :encrypted_key
      t.boolean :primary

      t.timestamps null: false
    end
  end
end
