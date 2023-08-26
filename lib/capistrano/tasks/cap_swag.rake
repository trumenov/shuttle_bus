namespace :cap_swag do
  # desc 'run run_rake_rswag'
  # task :run_rake_rswag do
  #   on roles(:app) do
  #     within "#{current_path}" do
  #       with rails_env: "#{fetch(:stage)}" do
  #         execute("pwd")
  #         execute("cd #{deploy_to}/current; pwd; /usr/bin/rbenv exec bundle exec rake my_swag:update_swagger_yaml RAILS_ENV=production")
  #       end
  #     end
  #   end
  # end
end
