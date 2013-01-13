class VersionController < ApplicationController

	before_filter :authenticate_user!
	before_filter :require_admin

	def index
		begin
			@git_version = ::File.read('./REVISION').chomp
		rescue Errno::ENOENT
		ensure
			@git_version ||= "Unknown (REVISION file is missing)"
		end
	end
end