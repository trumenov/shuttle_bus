# frozen_string_literal: true

class CeparserTask < ApplicationRecord
  belongs_to :task_queue


  def task_options_h
    task_options_json.to_s.json_as_h
  end
end
