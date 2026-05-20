require "test_helper"

class ToDoItemTest < ActiveSupport::TestCase
  test "saves a valid to-do" do
    todo = ToDoItem.create!(title: "Learn Minitest", description: "Write model tests")
    assert todo.persisted?
    assert_equal "Learn Minitest", todo.title
    assert_not todo.completed
  end
  test "loads fixture" do
    todo = to_do_item(:one)
    assert_equal "Buy milk", todo.title
  end
  test "completed defaults to false" do
    todo = ToDoItem.create!(title: "Default check")
    assert_equal false, todo.completed
  end
end
