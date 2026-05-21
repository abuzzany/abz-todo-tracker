require "test_helper"

class CompletedToDoItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @completed_to_do_item = to_do_item(:one)
  end

  test "should update completed_to_do_item" do
    patch completed_to_do_item_url(@completed_to_do_item), params: { completed_to_do_item: { completed: @completed_to_do_item.completed, completed_at: @completed_to_do_item.completed_at } }
    assert_redirected_to completed_to_do_item_url(@completed_to_do_item)
  end
end
