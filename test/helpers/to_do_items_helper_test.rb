require "test_helper"

class ToDoItemsHelperTest < ActionView::TestCase
  test "heatmap_grid builds full weeks of 7 days each" do
    today = Date.new(2026, 9, 6) # Sunday
    weeks = heatmap_grid({}, weeks: 13, today: today)

    assert_equal 13, weeks.length
    assert(weeks.all? { |week| week.length == 7 })
  end

  test "heatmap_grid's last week ends on today's calendar week" do
    today = Date.new(2026, 9, 9) # Wednesday
    weeks = heatmap_grid({}, weeks: 2, today: today)

    last_week = weeks.last
    assert_equal Date.new(2026, 9, 6), last_week.first[:date] # Sunday
    assert_equal Date.new(2026, 9, 12), last_week.last[:date] # Saturday
  end

  test "heatmap_grid marks dates after today as future, with no count or level" do
    today = Date.new(2026, 9, 9) # Wednesday
    weeks = heatmap_grid({}, weeks: 1, today: today)

    future_cell = weeks.last.find { |cell| cell[:date] == today + 1 }
    assert_nil future_cell[:count]
    assert_nil future_cell[:level]
  end

  test "heatmap_grid fills in counts from the given data, defaulting to zero" do
    today = Date.new(2026, 9, 9) # Wednesday, so today - 2 stays in the same calendar week
    counts = { today => 3, today - 1 => 0 }

    weeks = heatmap_grid(counts, weeks: 1, today: today)
    cells_by_date = weeks.flatten.index_by { |cell| cell[:date] }

    assert_equal 3, cells_by_date[today][:count]
    assert_equal 0, cells_by_date[today - 1][:count]
    assert_equal 0, cells_by_date[today - 2][:count]
  end

  test "heatmap_level maps completion counts to a 0-4 intensity scale" do
    assert_equal 0, heatmap_level(0)
    assert_equal 1, heatmap_level(1)
    assert_equal 2, heatmap_level(2)
    assert_equal 3, heatmap_level(3)
    assert_equal 4, heatmap_level(4)
    assert_equal 4, heatmap_level(10)
  end

  test "heatmap_cell_class maps each level to a distinct tailwind background class" do
    assert_equal "invisible", heatmap_cell_class(nil)

    classes = (0..4).map { |level| heatmap_cell_class(level) }
    assert_equal classes.uniq, classes
    assert classes.all? { |css_class| css_class.start_with?("bg-") }
  end

  test "heatmap_weekday_labels lists all 7 days starting from Sunday, matching heatmap_grid's row order" do
    today = Date.new(2026, 9, 9) # Wednesday
    first_week = heatmap_grid({}, weeks: 1, today: today).first

    labels = heatmap_weekday_labels

    assert_equal 7, labels.length
    assert_equal first_week.map { |cell| cell[:date].strftime("%a") }, labels
  end
end
