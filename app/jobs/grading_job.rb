class GradingJob < ApplicationJob
  queue_as :default

  def perform(submission_id)
    submission = Submission.find(submission_id)
    submission.update!(status: :pending)

    begin
      grader = GeminiGrader.new(
        content: submission.content,
        assignment_type: submission.assignment_type
      )
      feedback = grader.grade
      submission.update!(status: :completed, result: feedback)
    rescue => e
      submission.update!(status: :failed, result: { error: e.message })
    end
  end
end
