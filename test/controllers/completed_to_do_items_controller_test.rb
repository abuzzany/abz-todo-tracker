require "test_helper"

class CompletedToDoItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @completed_to_do_item = completed_to_do_items(:one)
  end

  test "should get index" do
    get completed_to_do_items_url
    assert_response :success
  end

  test "should get new" do
    get new_completed_to_do_item_url
    assert_response :success
  end

  test "should create completed_to_do_item" do
    assert_difference("CompletedToDoItem.count") do
      post completed_to_do_items_url, params: { completed_to_do_item: { completed: @completed_to_do_item.completed, completed_at: @completed_to_do_item.completed_at } }
    end

    assert_redirected_to completed_to_do_item_url(CompletedToDoItem.last)
  end

  test "should show completed_to_do_item" do
    get completed_to_do_item_url(@completed_to_do_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_completed_to_do_item_url(@completed_to_do_item)
    assert_response :success
  end

  test "should update completed_to_do_item" do
    patch completed_to_do_item_url(@completed_to_do_item), params: { completed_to_do_item: { completed: @completed_to_do_item.completed, completed_at: @completed_to_do_item.completed_at } }
    assert_redirected_to completed_to_do_item_url(@completed_to_do_item)
  end

  test "should destroy completed_to_do_item" do
    assert_difference("CompletedToDoItem.count", -1) do
      delete completed_to_do_item_url(@completed_to_do_item)
    end

    assert_redirected_to completed_to_do_items_url
  end
end
