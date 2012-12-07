# Deploy recipe for Restaurant Login application
set :application, "frab"

set :deploy_to, "/home/#{application}/app"
set :user, "#{application}"
set :port, 2222
set :use_sudo, false
set :scm, :git
set :repository, "ssh://git@github.com/ohm2013/frab.git"
set :keep_releases, 5
set :deploy_via, :remote_cache

# Tell Capistrano the servers it can play with
server "services.ifcat.org", :app, :web, :db, :primary => true

# RVM settigns
set :rvm_ruby_string, "ruby-1.9.3-p194@frab"
set :rvm_type, :user

# bundle options
set :bundle_without, [:development, :test]

# migrate to correct db version before restarting
before 'deploy:restart', 'deploy:migrate'

# Generate an additional task to fire up the thin clusters
namespace :deploy do
	desc "Start the Thin processes"
	task :start do
		run <<-CMD
      cd /home/#{application}/app/current; bundle exec thin start -C config/thin.yml
		CMD
	end

	desc "Stop the Thin processes"
	task :stop do
		run <<-CMD
      cd /home/#{application}/app/current; bundle exec thin stop -C config/thin.yml
		CMD
	end

	desc "Restart the Thin processes"
	task :restart do
		run <<-CMD
      cd /home/#{application}/app/current; bundle exec thin restart -C config/thin.yml
		CMD
	end
end

require "rvm/capistrano"
require "bundler/capistrano"
require "./lib/frab/capistrano_redis_yml"
require "./lib/frab/capistrano_database_yml"

load 'deploy/assets'
