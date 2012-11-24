class WelcomeController < ApplicationController
  def index
    # @TODO add tests for this
    # If only one conference, no need to let people choose, just redirect them.
    redirect_to new_cfp_session_path if @conferences.count == 1
  end
end
