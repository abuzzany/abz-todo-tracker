require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  setup do
    sign_in users(:one)
    @category = categories(:personal)
  end

  test "visiting the index" do
    visit categories_url
    assert_selector "h1", text: "Categories"
    assert_text @category.name
  end

  test "creating a category" do
    visit categories_url
    click_on "New category"

    fill_in "Name", with: "Fitness"
    click_on "Create Category"

    assert_text "Category was successfully created"
    assert_text "Fitness"
  end

  test "creating a category without a name shows an error" do
    visit new_category_url

    fill_in "Name", with: ""
    click_on "Create Category"

    assert_text "prohibited this category from being saved"
  end

  test "creating a duplicate category shows an error" do
    visit new_category_url

    fill_in "Name", with: @category.name.upcase
    click_on "Create Category"

    assert_text "prohibited this category from being saved"
  end

  test "editing a category" do
    visit categories_url
    within "#category_#{@category.id}" do
      click_on "Edit"
    end

    fill_in "Name", with: "Personal errands"
    click_on "Update Category"

    assert_text "Category was successfully updated"
    assert_text "Personal errands"
  end

  test "destroying a category" do
    visit categories_url
    within "#category_#{@category.id}" do
      click_on "Delete"
    end

    assert_text "Category was successfully destroyed"
    assert_no_text @category.name
  end
end
