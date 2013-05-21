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
end
