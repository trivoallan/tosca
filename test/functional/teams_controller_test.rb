require File.dirname(__FILE__) + '/../test_helper'

class TeamsControllerTest < ActionController::TestCase

  fixtures :teams, :demandes, :commentaires, :users, :contracts_users,
    :recipients, :clients, :statuts, :ingenieurs, :severites,
    :logiciels, :socles, :clients_socles, :versions, :permissions, :roles,
    :permissions_roles, :contracts, :contracts_commitments, :commitments,
    :typedemandes, :elapseds

  def test_should_get_index
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'index'

      assert_not_nil assigns(:teams)
    end
  end

  def test_should_create_team
    %w(admin manager).each do |l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'

      assert_difference('Team.count') do
        form = select_form 'form_team'
        form.team.name = "TestTeam#{l}"
        form.team.motto = "TestMotto"
        form.team.contact_id = 1
        form.submit
      end
      assert_redirected_to team_path(assigns(:team))
    end
  end

  def test_should_show_team
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :show, :id => teams(:team_ossa).id
      assert_response :success
    end
  end

  def test_should_get_edit
    %w(admin manager).each do |l|
      login l, l

      get :edit, :id => teams(:team_ossa).id
      assert_response :success
    end
  end

  def a_test_should_update_team
    %w(admin manager).each do |l|
      login l, l

      put :update, :id => teams(:one).id, :team => { }
      assert_redirected_to team_path(assigns(:team))
    end
  end

end
