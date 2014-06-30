class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.references :user, index: true
      t.text :content, null: false
      t.timestamps
    end
  end
end
