require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = FactoryGirl.create(:event)
    @conference = @event.conference
    login_as(:admin)
  end

  test "should get index" do
    get :index, :conference_acronym => @conference.acronym
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, :event => @event.attributes, :conference_acronym => @conference.acronym
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    get :show, :id => @event.to_param, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @event.to_param, :conference_acronym => @conference.acronym
    assert_response :success
  end

  test "should update event" do
    put :update, :id => @event.to_param, :event => @event.attributes, :conference_acronym => @conference.acronym
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, :id => @event.to_param, :conference_acronym => @conference.acronym 
    end

    assert_redirected_to events_path
  end

  test "#report should be successfull" do
    get :report, :conference_acronym => @conference.acronym, :filter => {:not_in_role => "speaker"}
    assert_response :success
  end

  test "#report should get events without certain event_users" do
    event_person = FactoryGirl.create(:event_person, :event => @event, :event_role => "speaker")
    orphan       = FactoryGirl.create(:event, :event_people => [], :conference => @conference)

    get :report, :conference_acronym => @conference.acronym, :filter => { :not_in_role => "speaker" }

    assert_equal 1, assigns(:events).length
    assert_equal [orphan], assigns(:events)
  end
end
