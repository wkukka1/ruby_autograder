class Submission < ApplicationRecord
  enum status: { pending: 0, completed: 1, failed: 2 }
  validates :content, presence: true
  validates :assignment_type, inclusion: { in: %w[text code math] }
end
