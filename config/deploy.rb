# config valid for current version and patch releases of Capistrano
lock "~> 3.17.0"

# server '192.168.1.8', port: 22, roles: [:web, :app, :db], primary: true
server '159.69.10.17', user: 'der2shop_guy', port: 56565, roles: [:web, :app, :db], primary: true

set :repo_url,        'git@github.com:trumenov/shuttle_bus.git'
set :application,     'shuttle_bus'

# If using Digital Ocean's Ruby on Rails Marketplace framework, your username is 'rails'
set :user,            'der2shop_guy'
set :puma_threads,    [2, 4]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
# set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :ssh_options,     { forward_agent: true, user: fetch(:user),
                        keys: %w(~/.ssh/rsa_chaky22222222_shuttle_bus_deploy),
                        port: 56565, auth_methods: ['publickey'] }
# set :ssh_options,     { forward_agent: true, user: fetch(:user) }
# default_run_options[:pty] = true
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

## Defaults:
# set :scm,           :git
set :branch,        :main
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before 'deploy:starting', 'puma:make_dirs'
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do

      # Update this to your branch name: master, main, etc. Here it's main
      unless `git rev-parse HEAD` == `git rev-parse origin/main`
        puts "WARNING: HEAD is not the same as origin/main"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      # before 'deploy:restart'
      invoke 'deploy'
    end
  end

  # desc 'Swagger tasks'
  # task :run_deploy_swager_tasks do
  #   on roles(:app) do
  #     invoke 'cap_swag:run_rake_rswag'
  #   end
  # end

  desc 'Restart application'
  task :restart do
      on roles(:app), in: :sequence, wait: 5 do
        # invoke 'puma:stop'
        # execute("rm -f #{deploy_to}/shared/tmp/pids/puma.pid")
        # invoke 'puma:start'
        invoke 'puma:restart'
      end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  # after  :finishing,    :run_deploy_swager_tasks
  # after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
