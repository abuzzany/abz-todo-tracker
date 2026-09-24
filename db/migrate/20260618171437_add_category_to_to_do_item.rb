class AddCategoryToToDoItem < ActiveRecord::Migration[8.1]
  def change
    add_column :to_do_items, :category, :string
  end
end
