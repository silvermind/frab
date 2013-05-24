require "test_helper"

class ReportsControllerTest < ActionController::TestCase
  setup do
    @conference = FactoryGirl.create(:conference)
    login_as(:admin)
  end

  test "#index should be successfull" do
    get :index, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "#index should list things to report on" do
    get :index, :conference_acronym => @conference.acronym
    assert_template "reports/_report_menu"
  end

  test "#show_events should allow all filters used in the menu" do
    %w{lectures_with_speaker
      lectures_not_confirmed
      unconfirmed_events
      events_that_are_workshops
      events_that_are_no_lectures
      events_without_speaker
      events_with_unusual_state_speakers
      event_timeslot_deviation}.each do |filter|
      get :show_events, :id => filter, :conference_acronym => @conference.acronym
      assert_response :success
    end
  end

  test "#show_people should allow all filters used in the menu" do
    %w{people_speaking_at people_with_a_note}.each do |filter|
      get :show_people, :id => filter, :conference_acronym => @conference.acronym
      assert_response :success
    end
  end

  test "#show_statistics should allow all filters used in the menu" do
    %w{event_timeslot_sum events_by_track}.each do |filter|
      get :show_statistics, :id => filter, :conference_acronym => @conference.acronym
      assert_response :success
    end
  end

  test "#show_events lectures_with_speaker" do
    @hit           = FactoryGirl.create(:event, :event_type => "lecture", :conference => @conference)
    FactoryGirl.create(:event_person, :event => @hit)
    @no_lecture    = FactoryGirl.create(:event, :conference => @conference)
    FactoryGirl.create(:event_person, :event => @no_lecture)
    @no_speaker    = FactoryGirl.create(:event, :event_type => "lecture", :conference => @conference)

    get :show_events, :id => "lectures_with_speaker", :conference_acronym => @conference.acronym
    assert_response :success

    assert_equal [@hit], assigns(:events)
    assert_not_equal assigns(:events), [@no_lecture]
    assert_not_equal assigns(:events), [@no_speaker]
  end

  # TODO: these need tests
  #%li= link_to "events that are unconfirmed", report_on_events_path("unconfirmed_events")
  #%li= link_to "list of all workshops", report_on_events_path('events_that_are_workshops')
  #%li= link_to "events that are neither lectures nor workshops", report_on_events_path('events_that_are_no_lectures')
  #%li= link_to "events without speaker", report_on_events_path('events_without_speaker')
  #%li= link_to "events with speakers in a problematic state", report_on_events_path("events_with_unusual_state_speakers")
  #%li= link_to "list all lectures with non default timeslots", report_on_events_path('event_timeslot_deviation')

  #%li= link_to "confirmed people speaking at conference", report_on_people_path("people_speaking_at")
  #%li= link_to "people with a note in their submission", report_on_people_path("people_with_a_note")

  #%li= link_to "used timeslots (hours)", report_on_statistics_path("event_timeslot_sum")
  #%li= link_to "event numbers by track", report_on_statistics_path("events_by_track")
end
