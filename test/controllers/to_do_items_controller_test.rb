require "test_helper"

class ToDoItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @to_do_item = to_do_item(:one)
  end

  test "should get index" do
    get to_do_items_url
    assert_response :success
  end

  test "index renders current streak, longest streak, and heatmap cells" do
    today = Date.current
    ToDoItem.create!(title: "Done today", completed: true, completed_at: today)
    ToDoItem.create!(title: "Done yesterday", completed: true, completed_at: today - 1)

    get to_do_items_url

    assert_response :success
    assert_select "#current-streak-value", text: "2"
    assert_select "#longest-streak-value", text: "2"
    assert_select "#completion-heatmap [data-heatmap-date='#{today}'][data-heatmap-count='1']"
  end

  test "index shows 15 items per page by default" do
    create_items(20) # plus 2 fixtures = 22 items

    get to_do_items_url

    assert_select "#to_do_items tbody tr", count: 15
    assert_select "#to_do_items_pagination", text: /Showing\s+1–15\s+of\s+22/
    assert_select "#current-page", text: "1"
    assert_select "a[rel=next][href=?]", to_do_items_path(page: 2)
    assert_select "a[rel=prev]", count: 0
  end

  test "index shows the remaining items on the last page" do
    create_items(20)

    get to_do_items_url(page: 2)

    assert_select "#to_do_items tbody tr", count: 7
    assert_select "#to_do_items_pagination", text: /Showing\s+16–22\s+of\s+22/
    assert_select "a[rel=prev][href=?]", to_do_items_path(page: 1)
    assert_select "a[rel=next]", count: 0
  end

  test "index clamps an out-of-range page to the last page" do
    create_items(20)

    get to_do_items_url(page: 99)

    assert_response :success
    assert_select "#current-page", text: "2"
  end

  test "index clamps an invalid page to the first page" do
    create_items(20)

    get to_do_items_url(page: "abc")

    assert_response :success
    assert_select "#current-page", text: "1"
  end

  test "index hides pagination when everything fits on one page" do
    get to_do_items_url

    assert_select "#to_do_items tbody tr", count: ToDoItem.count
    assert_select "#to_do_items_pagination", count: 0
  end

  test "index narrows the heatmap and streak to the selected category" do
    today = Date.current
    ToDoItem.create!(title: "Work today", completed: true, completed_at: today, category: categories(:work))
    ToDoItem.create!(title: "Personal today", completed: true, completed_at: today, category: categories(:personal))
    ToDoItem.create!(title: "Personal yesterday", completed: true, completed_at: today - 1, category: categories(:personal))

    get to_do_items_url(streak_category_id: categories(:personal).id)

    assert_select "#completion-heatmap [data-heatmap-date='#{today}'][data-heatmap-count='1']"
    assert_select "#completion-heatmap [data-heatmap-date='#{today - 1}'][data-heatmap-count='1']"
    assert_select "#category-streak", text: /Personal: current 2 days\s+·\s+longest 2 days/
    assert_select "#streak-category-filter a[aria-current=true]", text: "Personal"
    # The overall streak cards are not filtered.
    assert_select "#current-streak-value", text: "2"
  end

  test "index shows all categories in the heatmap by default or for an unknown category" do
    today = Date.current
    ToDoItem.create!(title: "Work today", completed: true, completed_at: today, category: categories(:work))
    ToDoItem.create!(title: "Personal today", completed: true, completed_at: today, category: categories(:personal))

    [ {}, { streak_category_id: "999999" } ].each do |params|
      get to_do_items_url(params)

      assert_select "#completion-heatmap [data-heatmap-date='#{today}'][data-heatmap-count='2']"
      assert_select "#category-streak", count: 0
      assert_select "#streak-category-filter a[aria-current=true]", text: "All"
    end
  end

  test "pagination links keep the selected streak category" do
    create_items(20)

    get to_do_items_url(streak_category_id: categories(:work).id)

    assert_select "a[rel=next][href=?]", to_do_items_path(streak_category_id: categories(:work).id, page: 2)
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

  test "should create to_do_item as json" do
    assert_difference("ToDoItem.count") do
      post to_do_items_url,
        params: { to_do_item: { title: "Learn controllers", description: "Integration test" } },
        as: :json
    end

    assert_response :created
    assert_equal "Learn controllers", ToDoItem.last.title
  end

  test "should not create to_do_item without a title" do
    assert_no_difference("ToDoItem.count") do
      post to_do_items_url, params: { to_do_item: { title: "" } }
    end

    assert_response :unprocessable_content
  end

  test "should not create to_do_item without a title as json" do
    assert_no_difference("ToDoItem.count") do
      post to_do_items_url, params: { to_do_item: { title: "" } }, as: :json
    end

    assert_response :unprocessable_content
  end

  test "should create a new category when new_category is given" do
    assert_difference("Category.count") do
      post to_do_items_url, params: { to_do_item: { title: "Read a book" }, new_category: "Leisure" }
    end

    assert_equal "Leisure", ToDoItem.last.category.name
  end

  test "should reuse an existing category regardless of case when new_category is given" do
    existing = categories(:personal)

    assert_no_difference("Category.count") do
      post to_do_items_url, params: { to_do_item: { title: "Buy stamps" }, new_category: existing.name.upcase }
    end

    assert_equal existing, ToDoItem.last.category
  end

  test "new_category takes priority over a selected category_id" do
    post to_do_items_url, params: {
      to_do_item: { title: "Priority check", category_id: categories(:work).id },
      new_category: categories(:personal).name
    }

    assert_equal categories(:personal), ToDoItem.last.category
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

  test "should not update to_do_item without a title" do
    patch to_do_item_url(@to_do_item), params: { to_do_item: { title: "" } }

    assert_response :unprocessable_content
    assert_equal "Buy milk", @to_do_item.reload.title
  end

  test "should destroy to_do_item" do
    assert_difference("ToDoItem.count", -1) do
      delete to_do_item_url(@to_do_item)
    end

    assert_redirected_to to_do_items_url
  end

  test "should destroy to_do_item as json" do
    assert_difference("ToDoItem.count", -1) do
      delete to_do_item_url(@to_do_item), as: :json
    end

    assert_response :no_content
  end

  private
    def create_items(count)
      count.times { |i| ToDoItem.create!(title: "Paginated item #{i + 1}") }
    end
end
