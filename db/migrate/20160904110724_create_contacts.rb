class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.text :photo_url
      t.text :interests
      t.string :name

      t.timestamps null: false
    end
  end
end
