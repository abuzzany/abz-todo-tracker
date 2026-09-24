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

  test "requires a title" do
    todo = ToDoItem.new(description: "No title given")
    assert_not todo.valid?
    assert_includes todo.errors[:title], "can't be blank"
  end

  test "does not require a description" do
    todo = ToDoItem.new(title: "Title only")
    assert todo.valid?
  end

  test "can be saved without a category" do
    todo = ToDoItem.create!(title: "Uncategorized")
    assert_nil todo.category
  end

  test "can be assigned a category" do
    todo = ToDoItem.create!(title: "Grocery run", category: categories(:personal))
    assert_equal categories(:personal), todo.category
  end

  test "completed_counts_by_day tallies completed items per completed_at date" do
    today = Date.current
    ToDoItem.create!(title: "First today", completed: true, completed_at: today)
    ToDoItem.create!(title: "Second today", completed: true, completed_at: today)
    ToDoItem.create!(title: "Yesterday", completed: true, completed_at: today - 1)

    counts = ToDoItem.completed_counts_by_day

    assert_equal 2, counts[today]
    assert_equal 1, counts[today - 1]
  end

  test "completed_counts_by_day excludes items that are not completed" do
    today = Date.current
    ToDoItem.create!(title: "Not completed", completed: false, completed_at: today)

    counts = ToDoItem.completed_counts_by_day

    assert_nil counts[today]
  end

  test "completed_counts_by_day excludes completed items without a completed_at date" do
    ToDoItem.create!(title: "Completed without a date", completed: true, completed_at: nil)

    assert_empty ToDoItem.completed_counts_by_day
  end

  test "completed_counts_by_day_and_category breaks down completions per day by category name" do
    today = Date.current
    ToDoItem.create!(title: "Work 1", completed: true, completed_at: today, category: categories(:work))
    ToDoItem.create!(title: "Work 2", completed: true, completed_at: today, category: categories(:work))
    ToDoItem.create!(title: "Personal", completed: true, completed_at: today, category: categories(:personal))
    ToDoItem.create!(title: "No category", completed: true, completed_at: today - 1)
    ToDoItem.create!(title: "Not done", completed: false, completed_at: today, category: categories(:work))

    counts = ToDoItem.completed_counts_by_day_and_category

    assert_equal({ "Work" => 2, "Personal" => 1 }, counts[today])
    assert_equal({ nil => 1 }, counts[today - 1])
  end
end
