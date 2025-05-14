class GradingJob < ApplicationJob
  queue_as :default

  retry_on HTTParty::Error, wait: 5.seconds, attempts: 3
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3

  discard_on ActiveJob::DeserializationError

  def perform(submission_id)
    submission = Submission.find(submission_id)

    submission.update!(status: :pending)

    begin
      grader = GeminiGrader.new(api_key: ENV.fetch('GEMINI_API_KEY'))
      feedback = grader.grade(
        content:          submission.content,
        assignment_type:  submission.assignment_type
      )

      submission.update!(
        status: :completed,
        result: feedback
      )

    rescue StandardError => e
      Rails.logger.error(
        "[GradingJob] Failed to grade submission=#{submission.id}: #{e.class} – #{e.message}"
      )

      submission.update!(
        status: :failed,
        result: { error: e.message }
      )

      raise
    end
  end
end
