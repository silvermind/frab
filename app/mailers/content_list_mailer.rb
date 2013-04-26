class ContentListMailer < ActionMailer::Base

	default :from => Settings['from_email']

	def notify_new_person(person)
		@person = person
		mail :to => Settings['content_mail'], :subject => I18n.t("mailers.content_list_mailer.notify_new_person")
	end

	def notify_updated_person(person)
		@person = person
		mail :to => Settings['content_mail'], :subject => I18n.t("mailers.content_list_mailer.notify_updated_person")
	end

	def notify_new_event(event)
		@event = event
		mail :to => Settings['content_mail'], :subject => I18n.t("mailers.content_list_mailer.notify_new_event")
	end

	def notify_updated_event(event)
		@event = event
		mail :to => Settings['content_mail'], :subject => I18n.t("mailers.content_list_mailer.notify_updated_event")
	end

	def notify_new_event_rating(event_rating)
		@event_rating = event_rating
		mail :to => Settings['content_mail'], :subject => I18n.t("mailers.content_list_mailer.notify_new_event_rating")
	end

	def notify_updated_event_rating(event_rating)
		@event_rating = event_rating
		mail :to => Settings['content_mail'], :subject => I18n.t("mailers.content_list_mailer.notify_updated_event_rating")
	end
end
