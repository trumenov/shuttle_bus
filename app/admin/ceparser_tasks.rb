# frozen_string_literal: true

ActiveAdmin.register(CeparserTask) do
  attributes_to_display = CeparserTask.new.attributes.keys - %w(id updated_at)
  # permit_params attributes_to_display.map(&:to_sym)
  permit_params :task_queue_id, :prio, :task_options_json, :take_await_seconds, :take_max_seconds
  # actions :index, :show, :edit, :update, :new

  index do
    selectable_column
    id_column
    attributes_to_display.each do |attribute|
      column attribute.to_sym
    end
    actions
  end

  # show do
  #   columns do
  #     column do
  #       attributes_table do
  #         attributes_to_display.each do |attribute|
  #           row attribute.to_sym
  #         end
  #       end
  #     end
  #   end
  #   active_admin_comments
  # end

  form do |f|
    f.inputs do
      f.input :task_queue
      f.input :prio
      f.input :task_options_json
      f.input :take_await_seconds
      f.input :take_max_seconds
    end
    f.actions
  end

  filter :id
  filter :task_queue
end
