class MissionControl::Jobs::JobsController < MissionControl::Jobs::ApplicationController
  include MissionControl::Jobs::JobScoped, MissionControl::Jobs::JobFilters

  skip_before_action :set_job, only: :index
  before_action :set_backtrace_cleaner, only: :show

  def index
    @job_class_names = jobs_with_status.job_class_names
    @queue_names = ActiveJob.queues.map(&:name)

    @jobs_page = MissionControl::Jobs::Page.new(filtered_jobs_with_status, page: params[:page].to_i)
    @jobs_count = @jobs_page.total_count
  end

  def show
  end

  private

    def jobs_relation
      filtered_jobs
    end

    def filtered_jobs_with_status
      filtered_jobs.with_status(jobs_status)
    end

    def jobs_with_status
      ActiveJob.jobs.with_status(jobs_status)
    end

    def filtered_jobs
      ActiveJob.jobs.where(**@job_filters)
    end

    helper_method :jobs_status

    def jobs_status
      params[:status].presence&.inquiry
    end

    def set_backtrace_cleaner
      @backtrace_cleaner = @application.servers[server_id]&.backtrace_cleaner
    end

    def server_id
      params[:server_id]
    end
end
