class Person < ActiveRecord::Base

  GENDERS = ["male", "female", "unspecified"]

  has_many :event_people
  has_many :phone_numbers
  has_many :im_accounts
  has_many :events, :through => :event_people, :uniq => true
  has_many :links, :as => :linkable
  has_many :languages, :as => :attachable
  has_many :availabilities
  has_many :event_ratings

  accepts_nested_attributes_for :phone_numbers, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :im_accounts, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :links, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :languages, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :availabilities, :reject_if => :all_blank

  belongs_to :user

  acts_as_indexed :fields => [:first_name, :last_name, :public_name, :email, :abstract, :description]

  has_paper_trail 

  has_attached_file :avatar, 
    :styles => {:tiny => "16x16>", :small => "32x32>", :large => "128x128>"},
    :default_url => "person_:style.png"

  validates_attachment_content_type :avatar, :content_type => [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :public_name, :email, :abstract

  validates_inclusion_of :gender, :in => GENDERS, :allow_nil => true

  scope :involved_in, lambda { |conference|
    joins(:events => :conference).where(:"conferences.id" => conference.id).group(:"people.id")
  }
  scope :without_events_in, lambda {|conference|
    joins("LEFT JOIN event_people ON event_people.person_id = people.id").group(:"people.id").having("SUM(CASE WHEN event_people.id > 0 then 1 ELSE 0 END) = 0")
  }
  scope :speaking_at, lambda { |conference|
    joins(:events => :conference).where(:"conferences.id" => conference.id).where(:"event_people.event_role" => ["speaker", "moderator"]).where(:"events.state" => ["unconfirmed", "confirmed"]).group(:"people.id")
  }
  scope :publicly_speaking_at, lambda { |conference|
    joins(:events => :conference).where(:"conferences.id" => conference.id).where(:"event_people.event_role" => ["speaker", "moderator"]).where(:"events.public" => true).where(:"events.state" => ["unconfirmed", "confirmed"]).group(:"people.id")
  }
  scope :confirmed, lambda { |conference|
    joins(:events => :conference).where(:"conferences.id" => conference.id).where(:"events.state" => "confirmed")
  }

  after_create :send_new_person_notification
  after_update :send_updated_person_notification

  def full_name
    if first_name.blank? or last_name.blank? and not public_name.blank?
      public_name
    else
      "#{first_name} #{last_name}"
    end
  end

  def full_public_name
    if public_name.blank?
      full_name
    else
      public_name
    end
  end

  def events_in(conference)
    self.events.where(:conference_id => conference.id).all
  end

  def public_and_accepted_events_as_speaker_in(conference)
    self.events.public.accepted.where(:"event_people.event_role" => ["speaker", "moderator"]).where(:conference_id => conference.id).all
  end

  def availabilities_in(conference)
    self.availabilities.where(:conference_id => conference.id)
  end

  def average_feedback_as_speaker
    events = self.event_people.where(:event_role => ["speaker", "moderator"]).map(&:event)
    feedback = 0.0
    count = 0
    events.each do |event|
      if current_feedback = event.average_feedback
        feedback += current_feedback
        count += 1
      end
    end
    return nil if count == 0
    feedback / count
  end

  def locale_for_mailing(conference)
    own_locales = self.languages.all.map{|l| l.code.downcase.to_sym}
    conference_locales = conference.languages.all.map{|l| l.code.downcase.to_sym}
    return :en if own_locales.include? :en or own_locales.empty? or (own_locales & conference_locales).empty?
    (own_locales & conference_locales).first
  end

  def send_new_person_notification
	  ContentListMailer.notify_new_person(@conference, self).deliver
  end

  def send_updated_person_notification
	  ContentListMailer.notify_updated_person(@conference, self).deliver
  end

  def to_s
    "Person: #{self.full_name}"
  end

end
