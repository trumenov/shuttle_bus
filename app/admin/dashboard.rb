ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do

      end

      column do
        extend ActiveAdmin::UserHelper

        if User.active.exists?
          panel "Users stats" do

            table do
              thead do
                tr do
                  th { "No data" }
                  th { "No data" }
                  th { "No data" }
                end
              end
              tbody do
                tr do
                  td do
                    # minimum_user_age
                  end
                  td do
                    # maximum_user_age
                  end
                  td do
                    # average_user_age
                  end
                end
              end
            end

          end
        end
      end
    end
  end
end
