require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    ActionMailer::Base.deliveries = []
    @event = FactoryGirl.create(:event, :state => "unconfirmed")
    @speaker = FactoryGirl.create(:person)
    FactoryGirl.create(:event_person, :event => @event, :person => @speaker, :event_role => "speaker")
    @coordinator = FactoryGirl.create(:person)
  end

  test "acceptance processing sends email if asked to" do
    @event.process_acceptance(:send_mail => true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  #test "acceptance processing does not send email by default" do
  #  @event.process_acceptance(:send_mail => false)
  #  assert ActionMailer::Base.deliveries.empty?
  #end

  test "acceptance processing sets coordinator" do
    assert_difference "EventPerson.count" do
      @event.process_acceptance(:coordinator => @coordinator)
    end
  end

  test "rejection processing sends email if asked to" do
    @event.process_rejection(:send_mail => true)
    assert !ActionMailer::Base.deliveries.empty?
  end

  #test "rejection processing does not send email by default" do
  #  @event.process_rejection(:send_mail => false)
  #  assert ActionMailer::Base.deliveries.empty?
  #end

  test "rejection processing sets coordinator" do
    assert_difference "EventPerson.count" do
      @event.process_rejection(:coordinator => @coordinator)
    end
  end

  test "correctly detects overlapping of events" do
    other_event = FactoryGirl.create(:event)
    other_event.start_time = @event.start_time.ago(30.minutes)
    assert @event.overlap?(other_event)
    other_event.start_time = @event.start_time.ago(1.hour)
    assert !@event.overlap?(other_event)
  end

  test "#without_role should filter events without the given role" do
    @without_speaker  = FactoryGirl.create(:event)
    FactoryGirl.create(:event_person, :event => @without_speaker, :person => @coordinator, :event_role => "coordinator")
    assert_equal [@event],            Event.without_role("coordinator")
    assert_equal [@without_speaker],  Event.without_role("speaker")
  end

  test "#without_role should include events without any role" do
    @without_any_role = FactoryGirl.create(:event)
    assert_equal [@without_any_role], Event.without_role("speaker")
  end

  test "should filter events with no role" do
    event_with_no_role = FactoryGirl.create(:event)
    assert_equal [], event_with_no_role.event_people
    assert_equal [event_with_no_role], Event.no_role
  end
end
