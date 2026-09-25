# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example data below is only loaded in development. Records are looked up by a stable key before being created, so
# re-running `bin/rails db:seed` updates the existing sample data instead of duplicating it.

return unless Rails.env.development?

# Demo account for signing in locally (every page requires a signed-in user).
User.find_or_create_by!(email: "demo@example.com") do |user|
  user.password = "password123"
end

categories = %w[Work Personal Health Learning Errands].index_with do |name|
  Category.find_or_create_by!(name: name)
end

# Open items, spread across categories (plus one uncategorized) so the list and filters have something to show.
[
  { title: "Prepare Q4 planning doc", description: "Outline goals and staffing needs for next quarter.", category: "Work" },
  { title: "Review open pull requests", description: "Clear out the review queue before standup.", category: "Work" },
  { title: "Book dentist appointment", description: nil, category: "Health" },
  { title: "Plan weekend hike", description: "Check the weather and pick a trail.", category: "Personal" },
  { title: "Finish Hotwire course chapter 4", description: "Turbo Streams and broadcasts.", category: "Learning" },
  { title: "Pick up dry cleaning", description: nil, category: "Errands" },
  { title: "Buy groceries", description: "Milk, eggs, coffee, spinach.", category: "Errands" },
  { title: "Water the plants", description: "No category on purpose.", category: nil }
].each do |attrs|
  item = ToDoItem.find_or_initialize_by(title: attrs[:title])
  item.update!(
    description: attrs[:description],
    category: attrs[:category] && categories.fetch(attrs[:category]),
    completed: false,
    completed_at: nil
  )
end

# Completion history over the last ~13 weeks (the heatmap's window) so the streak stats, heatmap and chart are
# populated. Forced runs guarantee a current streak ending today and a longer streak in the past; other days are
# filled deterministically so the result is the same on every run.
completed_templates = {
  "Work" => [ "Answer support emails", "Update project board", "Write weekly status report" ],
  "Personal" => [ "Call mom", "Tidy up the desk", "Journal for 10 minutes" ],
  "Health" => [ "Morning run", "Stretch for 15 minutes", "Meal prep lunches" ],
  "Learning" => [ "Read a chapter of POODR", "Practice Ruby katas", "Watch a RailsConf talk" ],
  "Errands" => [ "Take out recycling", "Pay utility bill", "Return library books" ]
}

current_streak_days = (0..5).to_a    # today back through 5 days ago
longest_streak_days = (30..45).to_a  # a 16-day run
gap_days = [ 6, 29, 46 ]             # keep the streaks separated

random = Random.new(42)
today = Date.current

(0..90).each do |days_ago|
  next if gap_days.include?(days_ago)

  count =
    if current_streak_days.include?(days_ago) || longest_streak_days.include?(days_ago)
      random.rand(1..4)
    else
      random.rand < 0.55 ? random.rand(1..3) : 0
    end

  count.times do |index|
    category_name = completed_templates.keys[random.rand(completed_templates.size)]
    seed_key = "Seeded history item (#{days_ago} days ago, ##{index + 1})"

    item = ToDoItem.find_or_initialize_by(description: seed_key)
    item.update!(
      title: completed_templates.fetch(category_name).sample(random: random),
      category: categories.fetch(category_name),
      completed: true,
      completed_at: today - days_ago
    )
  end
end

puts "Seeded #{Category.count} categories and #{ToDoItem.count} to-do items " \
     "(#{ToDoItem.where(completed: true).count} completed)."
