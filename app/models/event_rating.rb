class EventRating < ActiveRecord::Base

  belongs_to :event, :counter_cache => true
  belongs_to :person

  after_create :send_new_event_rating_notification
  after_update :send_updated_event_rating_notification
  after_save :update_average

  protected

  def update_average
    self.event.recalculate_average_rating!
  end

  def send_new_event_rating_notification
	  ContentListMailer.notify_new_event_rating(self).deliver
  end

  def send_updated_event_rating_notification
	  ContentListMailer.notify_updated_event_rating(self).deliver
  end

end
