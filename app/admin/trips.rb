# frozen_string_literal: true

ActiveAdmin.register Trip do
  attributes_to_display = Trip.new.attributes.keys - %w(id updated_at)
  permit_params attributes_to_display.map(&:to_sym)
  actions :index, :show

  index do
    selectable_column
    id_column
    attributes_to_display.each do |attribute|
      column attribute.to_sym
    end
    actions
  end

  show do
    columns do
      column do
        attributes_table do
          attributes_to_display.each do |attribute|
            row attribute.to_sym
          end
        end
      end
    end
    active_admin_comments
  end

  filter :id
  filter :name
end
