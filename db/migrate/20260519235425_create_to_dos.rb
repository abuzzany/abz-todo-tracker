class CreateToDos < ActiveRecord::Migration[8.1]
  def change
    create_table :to_do_items do |t|
      t.string :title
      t.text :description
      t.boolean :completed, default: false
      t.date :completed_at
      t.timestamps
    end
  end
end
