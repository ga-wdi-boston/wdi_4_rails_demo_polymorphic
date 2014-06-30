class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :user, index: true
      t.text :url, null: false
      t.text :title, null: false
      t.timestamps
    end
  end
end
