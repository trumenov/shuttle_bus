# frozen_string_literal: true

class TaskQueue < ApplicationRecord
  belongs_to :user
  has_many :ceparser_tasks


end
