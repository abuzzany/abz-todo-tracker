class ToDoItem < ApplicationRecord
  belongs_to :category, optional: true

  validates_presence_of :title

  # Hash of Date => number of items completed on that date, used to power the
  # completion streak stats and heatmap on the dashboard.
  def self.completed_counts_by_day
    where(completed: true).where.not(completed_at: nil).group(:completed_at).count
  end

  # Hash of Date => { category name => count } for completed items, used for
  # the heatmap's per-category filter and tooltips. Uncategorized items are
  # keyed under nil.
  def self.completed_counts_by_day_and_category
    where(completed: true).where.not(completed_at: nil)
      .left_joins(:category)
      .group(:completed_at, "categories.name")
      .count
      .each_with_object({}) do |((date, category_name), count), by_day|
        (by_day[date] ||= {})[category_name] = count
      end
  end
end
