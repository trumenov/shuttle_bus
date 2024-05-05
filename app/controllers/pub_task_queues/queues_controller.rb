# frozen_string_literal: true

class ::PubTaskQueues::QueuesController < ::PubTaskQueues::PubTaskQueuesBaseController
  skip_before_action :set_front_side_current_taskqueue, only: %w{index new create}


  def index
    raise('Not done.')
    # per_page = params[:per_page] || (request.format.json? ? 2 : 24)
    # @items = TaskQueue.all.page(params_page).per(per_page)
  end

  def show
    @item = @front_side_current_taskqueue
    tasks = @item.ceparser_tasks.reorder(task_queue_id: :desc, prio: :desc, id: :asc).page(1).per(2).map { |x| { id: x.id, task_options: x.task_options_h } }
    render json: { id: @item.id, tasks: tasks }
  end
end
