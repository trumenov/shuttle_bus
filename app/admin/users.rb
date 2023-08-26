# frozen_string_literal: true

ActiveAdmin.register User do
  attributes_to_display = User.new.attributes.keys - %w(id password_digest reset_password_token confirmation_token created_at)
  permit_params attributes_to_display.map(&:to_sym)
  actions :index, :show

  includes :avatar_attachment

  index do
    selectable_column
    id_column
    column :avatar_thumb do |user|
      if user.avatar.attached?
        div do
          image_tag(user.avatar_thumb)
        end
        div do
          link_to('full', user.avatar, target: :blank)
        end
      else
        'no_avatar'
      end
    end
    attributes_to_display.each do |attribute|
      column attribute.to_sym
    end
    actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :avatar_thumb do |user|
            if user.avatar.attached?
              div do
                image_tag(user.avatar_thumb)
              end
              div do
                link_to('full', user.avatar, target: :blank)
              end
            else
              'no_avatar'
            end
          end
          attributes_to_display.each do |attribute|
            row attribute.to_sym
          end
        end
      end

      column do
        panel 'Created trips' do
          table_for resource.trips do
            column(:id) { |x| link_to(x.id, admin_trip_path(x)) }
            column(:name) { |x| x.user_route.name }
            column :trip_start_time_with_default
          end
        end
      end
    end


    active_admin_comments
  end

  filter :id
  filter :name
  filter :last_name
  filter :email
end
