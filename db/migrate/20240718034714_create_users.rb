class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :avatar_url, null: false
      t.timestamps
    end
    add_index :users, :uid, unique: true
  end
end
