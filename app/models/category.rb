class Category < ApplicationRecord
  has_many :to_do_items, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
