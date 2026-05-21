require "test_helper"

class ToDoItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @to_do_item = to_do_items(:one)
  end

  test "should get index" do
    get to_do_items_url
    assert_response :success
  end

  test "should get new" do
    get new_to_do_item_url
    assert_response :success
  end

  test "should create to_do_item" do
    assert_difference("ToDoItem.count") do
      post to_do_items_url, params: { to_do_item: { description: @to_do_item.description, title: @to_do_item.title } }
    end

    assert_redirected_to to_do_item_url(ToDoItem.last)
  end

  test "should show to_do_item" do
    get to_do_item_url(@to_do_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_to_do_item_url(@to_do_item)
    assert_response :success
  end

  test "should update to_do_item" do
    patch to_do_item_url(@to_do_item), params: { to_do_item: { description: @to_do_item.description, title: @to_do_item.title } }
    assert_redirected_to to_do_item_url(@to_do_item)
  end

  test "should destroy to_do_item" do
    assert_difference("ToDoItem.count", -1) do
      delete to_do_item_url(@to_do_item)
    end

    assert_redirected_to to_do_items_url
  end
end
