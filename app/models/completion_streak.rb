# Computes streak stats (current and longest run of consecutive days) from a
# collection of dates on which at least one to-do item was completed.
class CompletionStreak
  def initialize(dates, today: Date.current)
    @dates = dates.uniq.sort
    @completed_on = @dates.each_with_object({}) { |date, set| set[date] = true }
    @today = today
  end

  # Consecutive days of completions leading up to today. If nothing has been
  # completed yet today, the streak still counts through yesterday so it
  # doesn't reset to zero before the day is over.
  def current
    reference = @completed_on[@today] ? @today : @today - 1
    return 0 unless @completed_on[reference]

    run_length_ending_at(reference)
  end

  # The longest run of consecutive days with a completion, anywhere in history.
  def longest
    return 0 if @dates.empty?

    longest_run = current_run = 1
    @dates.each_cons(2) do |previous_date, following_date|
      current_run = following_date == previous_date + 1 ? current_run + 1 : 1
      longest_run = current_run if current_run > longest_run
    end
    longest_run
  end

  private
    def run_length_ending_at(date)
      length = 0
      day = date
      while @completed_on[day]
        length += 1
        day -= 1
      end
      length
    end
end
