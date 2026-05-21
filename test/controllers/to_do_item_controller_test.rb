require "test_helper"

class ToDoItemControllerTest < ActionDispatch::IntegrationTest
  test "create saves a to-do item" do
    assert_difference "ToDoItem.count", 1 do
      post to_do_items_path, params: {
        to_do_item: { title: "Learn controllers", description: "Integration test" }
      }
    end
    assert_response :created
    item = ToDoItem.last
    assert_equal "Learn controllers", item.title
  end
  test "create with invalid data does not save" do
    # once you add validations, e.g. validates :title, presence: true
    assert_no_difference "ToDoItem.count" do
      post to_do_items_path, params: { to_do_item: { title: "" } }
    end
    assert_response :unprocessable_entity
  end
end
