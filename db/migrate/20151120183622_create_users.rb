class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false, unique: true
      t.string :name, null: false

      t.string :password, null: true
      t.string :external_auth, null: true

      t.string :uploader_token, null: true

      t.timestamps null: false
    end
  end
end
