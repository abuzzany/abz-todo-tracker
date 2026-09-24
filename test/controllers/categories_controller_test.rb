require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:personal)
  end

  test "should get index" do
    get categories_url
    assert_response :success
    assert_select "body", text: /#{@category.name}/
  end

  test "should get new" do
    get new_category_url
    assert_response :success
  end

  test "should create category" do
    assert_difference("Category.count") do
      post categories_url, params: { category: { name: "Health" } }
    end

    assert_redirected_to categories_url
  end

  test "should create category as json" do
    assert_difference("Category.count") do
      post categories_url, params: { category: { name: "Health" } }, as: :json
    end

    assert_response :created
  end

  test "should not create category without a name" do
    assert_no_difference("Category.count") do
      post categories_url, params: { category: { name: "" } }
    end

    assert_response :unprocessable_content
  end

  test "should not create a duplicate category regardless of case" do
    assert_no_difference("Category.count") do
      post categories_url, params: { category: { name: @category.name.upcase } }
    end

    assert_response :unprocessable_content
  end

  test "should show category" do
    get category_url(@category)
    assert_response :success
  end

  test "should get edit" do
    get edit_category_url(@category)
    assert_response :success
  end

  test "should update category" do
    patch category_url(@category), params: { category: { name: "Personal errands" } }
    assert_redirected_to categories_url
    assert_equal "Personal errands", @category.reload.name
  end

  test "should not update category with a blank name" do
    patch category_url(@category), params: { category: { name: "" } }

    assert_response :unprocessable_content
    assert_equal "Personal", @category.reload.name
  end

  test "should destroy category" do
    assert_difference("Category.count", -1) do
      delete category_url(@category)
    end

    assert_redirected_to categories_url
  end

  test "destroying a category leaves its to_do_items uncategorized" do
    item = to_do_item(:one)
    assert_equal @category, item.category

    delete category_url(@category)

    assert_nil item.reload.category
  end
end
