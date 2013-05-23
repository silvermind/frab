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
set :test_log, "log/capistrano.test.log"
set :skip_tests, fetch(:skip_tests, "false")
set :branch, fetch(:branch, "master")

# Tell Capistrano the servers it can play with
server "services.ifcat.org", :app, :web, :db, :primary => true

# RVM settings
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

desc "Show currently deployed revision on server."
task :revisions, :roles => :app do
	current, previous, latest = current_revision[0,7], previous_revision[0,7], real_revision[0,7]
	puts "\n----------------------------------------------------------------------------------------------"
	puts "Master Revision: #{latest}"
	puts "\n\n"
	puts "#{application.capitalize}"
	puts "Deployed Revision: #{current}"
	puts "Previous Revision: #{previous}"
	puts "\n\n"

	# If deployed and master are the same, show the difference between the last 2 deployments.
	base_label, new_label, base_rev, new_rev = latest != current ? \
       ["deployed", "master", current, latest] : \
       ["previous", "deployed", previous, current]

	# Show difference between master and deployed revisions.
	if (diff = `git log #{base_rev}..#{new_rev} --oneline`) != ""
		version_data = "New version #{new_rev} deployed on #{Time.now}\n"
		version_data << "<ul>"
		version_data << `git log #{base_rev}..#{new_rev} --pretty=format:"<li>%h %cd : %s by %an</li>"`
		version_data << "</ul>"

		# Colorize refs
		diff.gsub!(/^([a-f0-9]+) /, "\033[1;32m\\1\033[0m - ")
		diff = "    " << diff.gsub("\n", "\n    ") << "\n"

		# Indent commit messages nicely, max 80 chars per line, line has to end with space.
		diff = diff.split("\n").map{|l|l.scan(/.{1,120}/).join("\n"<<" "*14).gsub(/([^ ]*)\n {14}/m,"\n"<<" "*14<<"\\1")}.join("\n")
		puts "=== Difference between #{base_label} revision and #{new_label} revision:\n\n"
		puts diff

	end
end
after "deploy", "revisions"

# run tests before deploy
namespace :deploy do
	before 'deploy:update_code' do

		if "#{skip_tests}" == "true"
			puts "\n"
			puts "-"*70
			puts "Deploying for branch: '#{branch}' in environment: '#{rails_env}'".yellow
			puts ">>> SKIPPING TESTS <<<<".yellow
			puts "-"*70
		else
			puts "--> Running tests, please wait ..."
			puts "\n"
			puts "-"*70
			puts "Deploying for branch: '#{branch}' in environment: '#{rails_env}'"
			puts "Running tests, please wait..."
			puts "-"*70
			unless system "bundle exec rake" #script/chrome_tests" #' > /dev/null'
				puts "********************"
				puts "********************"
				puts "********************"
				puts "--> Tests failed."
				puts "********************"
				puts "********************"
				puts "********************"
				exit
			else
				puts "********************"
				puts "--> Tests passed <--"
				puts "********************"
			end
		end
	end
end


require "rvm/capistrano"
require "bundler/capistrano"
require "whenever/capistrano"
require "sidekiq/capistrano"

require "./lib/frab/capistrano_redis_yml"
require "./lib/frab/capistrano_database_yml"
require "../lib/frab/capistrano_initializers_secret_token_rb"

load 'deploy/assets'
