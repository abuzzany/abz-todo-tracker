module ToDoItemsHelper
  # Builds a GitHub-style contribution grid: an array of weeks, each an array
  # of 7 day cells (Sunday first) running up to and including today's week.
  # Cells after today are padding to complete the final week and carry a nil
  # count/level so the view can render them invisibly.
  def heatmap_grid(counts_by_date, weeks: 13, today: Date.current)
    end_of_week = today + (6 - today.wday)
    start_of_grid = end_of_week - (weeks * 7 - 1)

    (start_of_grid..end_of_week).each_slice(7).map do |week|
      week.map do |date|
        if date > today
          { date: date, count: nil, level: nil }
        else
          count = counts_by_date[date] || 0
          { date: date, count: count, level: heatmap_level(count) }
        end
      end
    end
  end

  # Maps a completion count to a 0-4 intensity level for coloring a cell.
  def heatmap_level(count)
    [ count, 4 ].min
  end

  # Tailwind background class for a heatmap cell's intensity level.
  def heatmap_cell_class(level)
    {
      nil => "invisible",
      0 => "bg-gray-100",
      1 => "bg-green-200",
      2 => "bg-green-400",
      3 => "bg-green-600",
      4 => "bg-green-800"
    }.fetch(level)
  end

  # Weekday labels for the heatmap's row labels, Sunday first to match the
  # row order heatmap_grid produces within each week.
  def heatmap_weekday_labels
    %w[Sun Mon Tue Wed Thu Fri Sat]
  end
end
