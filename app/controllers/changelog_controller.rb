# encoding: UTF-8

# Render the ChangeLog
class ChangelogController < ApplicationController

  # Index
  def index
    change_log_fn = ::Rails.root.join('ChangeLog')
    if File.exists? change_log_fn
      @change_log = File.read change_log_fn
    else
      @change_log = 'Cannot find the ChangeLog file'
    end
  end
end