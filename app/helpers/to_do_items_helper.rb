module ToDoItemsHelper
  # Builds a GitHub-style contribution grid: an array of weeks, each an array
  # of 7 day cells (Sunday first) running up to and including today's week.
  # Cells after today are padding to complete the final week and carry a nil
  # count/level so the view can render them invisibly.
  def heatmap_grid(counts_by_date, weeks: 52, today: Date.current)
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

  # Short month name for a heatmap week (column) that contains the 1st of a
  # month, so month labels line up with where each month starts; nil otherwise.
  def heatmap_month_label(week)
    first_of_month = week.find { |cell| cell[:date].day == 1 }
    first_of_month && first_of_month[:date].strftime("%b")
  end

  # Tooltip for a heatmap cell: the weekday and date, how many tasks were
  # completed, and (when not filtered to one category) a per-category breakdown.
  def heatmap_cell_title(cell, breakdown_by_day, category: nil)
    return "" if cell[:count].nil?

    day = cell[:date].strftime("%A, %b %-d, %Y")
    if category
      "#{day} · #{pluralize(cell[:count], "#{category.name} task")} completed"
    else
      counts = (breakdown_by_day[cell[:date]] || {}).sort_by { |name, count| [ -count, name.to_s ] }
      details = counts.map { |name, count| "#{name || "No category"}: #{count}" }.join(", ")
      title = "#{day} · #{pluralize(cell[:count], "task")} completed"
      details.present? ? "#{title} (#{details})" : title
    end
  end

  # Link to the dashboard with the heatmap narrowed to one category (or all of
  # them when nil), keeping the other query params such as the table's page.
  def streak_category_path(category)
    to_do_items_path(request.query_parameters.except("streak_category_id").merge(category ? { "streak_category_id" => category.id } : {}))
  end

  # Weekday labels for the heatmap's row labels, Sunday first to match the
  # row order heatmap_grid produces within each week.
  def heatmap_weekday_labels
    %w[Sun Mon Tue Wed Thu Fri Sat]
  end
end
