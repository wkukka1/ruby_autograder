class SubmissionsController < ApplicationController
  def create
    submission = Submission.create!(
      content: params.require(:content),
      assignment_type: params.require(:assignment_type)
    )
    GradingJob.perform_later(submission.id)
    render json: { id: submission.id, status: submission.status }, status: :accepted
  end

  def show
    submission = Submission.find(params[:id])
    render json: {
      id: submission.id,
      status: submission.status,
      result: submission.result
    }
  end
end
