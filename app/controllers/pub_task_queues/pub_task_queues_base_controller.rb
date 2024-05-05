# frozen_string_literal: true

class ::PubTaskQueues::PubTaskQueuesBaseController < ::PagesController
  add_breadcrumb "TaskQueues", :queues_path
  before_action :set_front_side_current_taskqueue

  def set_front_side_current_taskqueue
    return @front_side_current_taskqueue if @front_side_current_taskqueue
    id = params[:tq_id] || params[:queue_tq_id]
    result = TaskQueue.find(Integer(id))
    unless result
      raise ActionController::RoutingError.new("TaskQueue[#{ id }] not found")
    end
    main_data[:title] = "TaskQueue \##{ result.id }"
    add_breadcrumb main_data[:title], queue_path(result.id)
    @front_side_current_taskqueue = result
    result
  end
end
