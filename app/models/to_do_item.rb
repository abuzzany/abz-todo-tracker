class ToDoItem < ApplicationRecord
  belongs_to :category, optional: true

  validates_presence_of :title

  # Hash of Date => number of items completed on that date, used to power the
  # completion streak stats and heatmap on the dashboard.
  def self.completed_counts_by_day
    where(completed: true).where.not(completed_at: nil).group(:completed_at).count
  end
end
