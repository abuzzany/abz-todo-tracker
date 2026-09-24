require "test_helper"

class CompletionStreakTest < ActiveSupport::TestCase
  test "current streak is zero with no completed dates" do
    streak = CompletionStreak.new([])
    assert_equal 0, streak.current
  end

  test "current streak counts consecutive days ending today" do
    today = Date.new(2026, 9, 6)
    dates = [ today, today - 1, today - 2 ]

    streak = CompletionStreak.new(dates, today: today)

    assert_equal 3, streak.current
  end

  test "current streak still counts through yesterday when today has no completion yet" do
    today = Date.new(2026, 9, 6)
    dates = [ today - 1, today - 2 ]

    streak = CompletionStreak.new(dates, today: today)

    assert_equal 2, streak.current
  end

  test "current streak is zero once a day is missed" do
    today = Date.new(2026, 9, 6)
    dates = [ today - 2, today - 3 ]

    streak = CompletionStreak.new(dates, today: today)

    assert_equal 0, streak.current
  end

  test "current streak ignores gaps further in the past" do
    today = Date.new(2026, 9, 6)
    dates = [ today, today - 1, today - 5, today - 6 ]

    streak = CompletionStreak.new(dates, today: today)

    assert_equal 2, streak.current
  end

  test "current streak handles duplicate dates" do
    today = Date.new(2026, 9, 6)
    dates = [ today, today, today - 1 ]

    streak = CompletionStreak.new(dates, today: today)

    assert_equal 2, streak.current
  end

  test "longest streak is zero with no completed dates" do
    streak = CompletionStreak.new([])
    assert_equal 0, streak.longest
  end

  test "longest streak finds the longest run across gaps" do
    today = Date.new(2026, 9, 6)
    dates = [
      today - 20, today - 19, today - 18, today - 17, # run of 4, in the past
      today - 10, today - 9,                          # run of 2
      today, today - 1                                 # run of 2, current
    ]

    streak = CompletionStreak.new(dates, today: today)

    assert_equal 4, streak.longest
  end

  test "longest streak equals current streak when there is only one run" do
    today = Date.new(2026, 9, 6)
    dates = [ today, today - 1, today - 2 ]

    streak = CompletionStreak.new(dates, today: today)

    assert_equal 3, streak.longest
    assert_equal streak.current, streak.longest
  end

  test "longest streak is unaffected by date order" do
    today = Date.new(2026, 9, 6)
    dates = [ today - 1, today - 5, today, today - 6, today - 4 ]

    streak = CompletionStreak.new(dates, today: today)

    assert_equal 3, streak.longest
  end
end
