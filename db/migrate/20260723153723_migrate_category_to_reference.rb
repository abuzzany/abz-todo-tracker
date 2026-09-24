class MigrateCategoryToReference < ActiveRecord::Migration[8.1]
  class MigrationCategory < ApplicationRecord
    self.table_name = "categories"
  end

  class MigrationToDoItem < ApplicationRecord
    self.table_name = "to_do_items"
  end

  def up
    add_reference :to_do_items, :category, foreign_key: true, index: true

    MigrationToDoItem.reset_column_information
    MigrationToDoItem.where.not(category: [ nil, "" ]).distinct.pluck(:category).each do |name|
      category = MigrationCategory.find_or_create_by!(name: name.strip)
      MigrationToDoItem.where(category: name).update_all(category_id: category.id)
    end

    remove_column :to_do_items, :category, :string
  end

  def down
    add_column :to_do_items, :category, :string

    MigrationToDoItem.reset_column_information
    MigrationCategory.find_each do |category|
      MigrationToDoItem.where(category_id: category.id).update_all(category: category.name)
    end

    remove_reference :to_do_items, :category, foreign_key: true, index: true
  end
end
