# encoding: UTF-8
#----------------------------------------------------------------------------
# Send notifications to content group
#
class ContentListMailer < ActionMailer::Base

  default from: Settings['from_email']

  # Send notification for addition of new person
  # @param person The person added
  def notify_new_person(conference, person)
    @person = person
    @conference = conference
    mail to: Settings['content_mail'],
         subject: I18n.t("mailers.content_list_mailer.notify_new_person")
  end

  # Send notification for update of person
  # @param person The updated person
  def notify_updated_person(conference, person)
    @person = person
    @conference = conference
    mail to: Settings['content_mail'],
         subject: I18n.t("mailers.content_list_mailer.notify_updated_person")
  end

  # Send notification of new event
  # @param event the new event
  def notify_new_event(event)
    @event = event
    mail to: Settings['content_mail'],
         subject: I18n.t("mailers.content_list_mailer.notify_new_event")
  end

  # Send notification of event update
  # @param event the updated event
  def notify_updated_event(event)
    @event = event
    mail to: Settings['content_mail'],
         subject: I18n.t("mailers.content_list_mailer.notify_updated_event")
  end

  # Send notification of new event rating
  # @param event_rating the new event rating
  def notify_new_event_rating(event_rating)
    @event_rating = event_rating
    mail to: Settings['content_mail'],
         subject: I18n.t("mailers.content_list_mailer.notify_new_event_rating")
  end

  # Send notification of event rating update
  # @param event_rating the updated event rating
  def notify_updated_event_rating(event_rating)
    @event_rating = event_rating
    mail to: Settings['content_mail'],
         subject: I18n.t("mailers.content_list_mailer.notify_updated_event_rating")
  end
end
