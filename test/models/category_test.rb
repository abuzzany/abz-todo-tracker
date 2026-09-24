require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "saves a valid category" do
    category = Category.create(name: "Errands")
    assert category.persisted?
  end

  test "requires a name" do
    category = Category.new
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "rejects a duplicate name regardless of case" do
    duplicate = Category.new(name: categories(:work).name.upcase)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "has many to_do_items" do
    category = categories(:personal)
    assert_includes category.to_do_items, to_do_item(:one)
  end

  test "destroying a category nullifies its to_do_items instead of deleting them" do
    category = categories(:personal)
    item = to_do_item(:one)
    assert_equal category, item.category

    category.destroy

    assert_equal true, item.reload.persisted?
    assert_nil item.category
  end
end
