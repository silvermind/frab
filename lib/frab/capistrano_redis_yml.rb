#
# = Capistrano redis.yml.erb task
#
# Provides a couple of tasks for creating the redis.yml.erb
# configuration file dynamically when deploy:setup is run.
#
# Category::    Capistrano
# Package::     Redis
# Author::      Ruurd Pels <rfpels@gmail.com>
# Copyright::   2012 The Authors
# License::     MIT License
#
#
# == Requirements
#
# This extension requires the original <tt>config/redis.yml</tt> to be excluded
# from source code checkout. You can easily accomplish this by renaming
# the file (for example to redis.example.yml) and appending <tt>redis.yml</tt>
# value to your SCM ignore list.
#
#   # Example for Subversion
#
#   $ svn mv config/redis.yml config/redis.example.yml
#   $ svn propset svn:ignore 'redis.yml' config
#
#   # Example for Git
#
#   $ git mv config/redis.yml config/redis.example.yml
#   $ echo 'config/redis.yml' >> .gitignore
#
#
# == Usage
#
# Include this file in your <tt>deploy.rb</tt> configuration file.
# Assuming you saved this recipe as capistrano_redis_yml.rb:
#
#   require "capistrano_redis_yml"
#
# Now, when <tt>deploy:setup</tt> is called, this script will automatically
# create the <tt>redis.yml</tt> file in the shared folder.
# Each time you run a deploy, this script will also create a symlink
# from your application <tt>config/redis.yml</tt> pointing to the shared configuration file.
#
# == Custom template
#
# By default, this script creates an exact copy of the default
# <tt>redis.yml</tt> file shipped with a new Rails 2.x application.
# If you want to overwrite the default template, simply create a custom Erb template
# called <tt>redis.yml.erb</tt> and save it into <tt>config/deploy</tt> folder.
#
# Although the name of the file can't be changed, you can customize the directory
# where it is stored defining a variable called <tt>:template_dir</tt>.
#
#   # store your custom template at foo/bar/redis.yml.erb
#   set :template_dir, "foo/bar"
#
#   # example of redis template
#
#   development:
#     redis:
#	    url: redis://localhost:6379
#   production:
#	  redis:
#	    url: redis://localhost:6379
#   test: &test
#     redis:
#       url: redis://localhost:6379/0
#   cucumber:
#     <<: *test
#
# Because this is an Erb template, you can place variables and Ruby scripts
# within the file.
# For instance, the template above takes advantage of Capistrano CLI
# to ask for a MySQL redis password instead of hard coding it into the template.
#
# === Password prompt
#
# For security reasons, in the example below the password is not
# hard coded (or stored in a variable) but asked on setup.
# I don't like to store passwords in files under version control
# because they will live forever in your history.
# This is why I use the Capistrano::CLI utility.
#

unless Capistrano::Configuration.respond_to?(:instance)
	abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

	namespace :deploy do

		namespace :redis do

			desc <<-DESC
        Creates the redis.yml configuration file in shared path.

        By default, this task uses a template unless a template \
        called redis.yml.erb is found either is :template_dir \
        or /config/deploy folders. The default template matches \
        the template for config/redis.yml file shipped with Rails.

        When this recipe is loaded, db:setup is automatically configured \
        to be invoked after deploy:setup. You can skip this task setting \
        the variable :skip_db_setup to true. This is especially useful \
        if you are using this recipe in combination with \
        capistrano-ext/multistaging to avoid multiple db:setup calls \
        when running deploy:setup for all stages one by one.
			DESC
			task :setup, :except => { :no_release => true } do

				default_template = <<-EOF
        development:
          url:  redis://localhost:6379
        test: &test
          url:  redis://localhost:6379
        production:
          url:  redis://localhost:6379
        cucumber:
          <<: *test
				EOF

				location = fetch(:template_dir, "config/deploy") + '/redis.yml.erb'
				template = File.file?(location) ? File.read(location) : default_template

				config = ERB.new(template)

				run "mkdir -p #{shared_path}/config"
				put config.result(binding), "#{shared_path}/config/redis.yml"
			end

			desc <<-DESC
        [internal] Updates the symlink for redis.yml file to the just deployed release.
			DESC
			task :symlink, :except => { :no_release => true } do
				run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
			end

		end

		after "deploy:setup",           "deploy:redis:setup"   unless fetch(:skip_redis_setup, false)
		after "deploy:finalize_update", "deploy:redis:symlink"

	end

end
