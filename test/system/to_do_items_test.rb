require "application_system_test_case"

class ToDoItemsTest < ApplicationSystemTestCase
  setup do
    @to_do_item = to_do_item(:one)
  end

  test "visiting the index" do
    visit to_do_items_url
    assert_selector "h1", text: "Dashboard"
    assert_text @to_do_item.title
  end

  test "seeing the completion streak after completing tasks on consecutive days" do
    today = Date.current
    ToDoItem.create!(title: "Done today", completed: true, completed_at: today)
    ToDoItem.create!(title: "Done yesterday", completed: true, completed_at: today - 1)

    visit to_do_items_url

    assert_text "Current streak"
    assert_selector "#current-streak-value", text: "2"
    assert_selector "#longest-streak-value", text: "2"
    assert_selector "#completion-heatmap [data-heatmap-date='#{today}'][data-heatmap-count='1']", visible: :all
    assert_selector "#completion-heatmap-labels", text: "Sun"
    assert_selector "#completion-heatmap-labels", text: "Sat"
  end

  test "paging through to do items" do
    20.times { |i| ToDoItem.create!(title: "Paginated item #{i + 1}") }

    visit to_do_items_url
    assert_selector "#to_do_items tbody tr", count: 15
    assert_no_text "Paginated item 20"

    click_on "Next"

    assert_selector "#current-page", text: "2"
    assert_selector "#to_do_items tbody tr", count: 7
    assert_text "Paginated item 20"
    assert_current_path to_do_items_path(page: 2)

    click_on "Previous"

    assert_selector "#current-page", text: "1"
    assert_selector "#to_do_items tbody tr", count: 15
  end

  test "creating a to do item" do
    visit to_do_items_url
    click_on "New to do item"

    fill_in "Title", with: "Walk the dog"
    fill_in "Description", with: "Around the block"
    fill_in "Or add a new category", with: "Pets"
    click_on "Create To do item"

    assert_text "To do item was successfully created"
    assert_text "Walk the dog"
    assert_text "Pets"
  end

  test "creating a to do item without a title shows an error" do
    visit new_to_do_item_url

    fill_in "Description", with: "Missing a title"
    click_on "Create To do item"

    assert_text "prohibited this to_do_item from being saved"
  end

  test "updating a to do item" do
    visit to_do_item_url(@to_do_item)
    click_on "Edit"

    fill_in "Title", with: "Buy oat milk"
    click_on "Update To do item"

    assert_text "To do item was successfully updated"
    assert_text "Buy oat milk"
  end

  test "destroying a to do item" do
    visit to_do_item_url(@to_do_item)
    click_on "Delete"

    assert_text "To do item was successfully destroyed"
  end
end
