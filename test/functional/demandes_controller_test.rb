require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
# class DemandesController; def rescue_action(e) raise e end; end
class DemandesControllerTest < ActionController::TestCase

  fixtures :demandes, :commentaires, :users, :contrats_users,
    :beneficiaires, :clients, :statuts, :ingenieurs, :severites,
    :logiciels, :socles, :clients_socles, :paquets, :permissions, :roles,
    :permissions_roles, :contrats, :contrats_engagements, :engagements,
    :piecejointes, :typedemandes

  def test_pending
    %w(admin manager expert customer).each do |l|
      login l, l
      get :pending
      assert_response :success
      assert_template 'pending'
    end
  end

  def test_index
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'index'

      check_ajax_filter(:contrat_id, Contrat.find(:first).id, :demandes)
      check_ajax_filter(:ingenieur_id, Ingenieur.find(:first).id, :demandes)
      check_ajax_filter(:typedemande_id, Typedemande.find(:first).id, :demandes)
      check_ajax_filter(:severite_id, Severite.find(:first).id, :demandes)
      check_ajax_filter(:statut_id, Statut.find(:first).id, :demandes)
      # The search box cannot be checked with the helper
      xhr :get, :index, :filters => { :text => "openoffice" }
      assert_response :success
    end
  end

  def test_edit
    %w(admin manager).each do |l|
      login l, l
      get :edit, :id => Demande.find(:first).id
      assert_response :success
      assert_template 'edit'

      _test_ajax_form_methods
      logout
    end
  end

  def test_new
    %w(admin manager expert customer).each do |l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'

      _test_ajax_form_methods
      logout
    end
  end

  def test_create
    %w(admin manager expert customer).each {|l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'

      form = select_form 'main_form'
      form.demande.resume = "there is a problem with foo"
      form.demande.description = "it's a bar"
      form.submit

      # p assigns(:demande).errors.full_messages
      assert_response :redirect
      # TODO : I did not manage to test correctly :
      # redirected with an url starting with new_demandes_path
      assert assigns(:demande).errors.empty?
      # It ensure that contract won't be passed between 2 logins
      # since the controller is the same instance in test environnement
      assigns(:demande).contrat = nil
    }
  end

  def test_show
    %w(admin manager expert customer viewer).each {|l|
      login l, l
      request_id = session[:user].contrats.first.demandes.first.id
      get :show, :id => request_id
      assert_response :success
      assert_template 'show'

      xhr :get, :ajax_description, :id => request_id
      assert_response :success
      assert_template 'demandes/tabs/_tab_description'

      xhr :get, :ajax_comments, :id => request_id
      assert_response :success
      assert_template 'demandes/tabs/_tab_comments'

      xhr :get, :ajax_history, :id => request_id
      assert_response :success
      assert_template 'demandes/tabs/_tab_history'

      xhr :get, :ajax_appels, :id => request_id
      assert_response :success
      assert_template 'demandes/tabs/_tab_appels'

      xhr :get, :ajax_piecejointes, :id => request_id
      assert_response :success
      assert_template 'demandes/tabs/_tab_piecejointes'

      xhr :get, :ajax_cns, :id => request_id
      assert_response :success
      assert_template 'demandes/tabs/_tab_cns'
    }
  end

  def test_link_contribution
    %w(admin manager expert).each { |l|
      login l, l
      request = session[:user].contrats.first.demandes.first
      contribution_id = request.logiciel.contributions.first.id

      post :link_contribution, :id => request.id, :contribution_id => contribution_id
      assert_response :redirect
      assert_redirected_to demande_path(request.id)
      assert flash.has_key?(:notice)
      assert !flash.has_key?(:warning)

      post :unlink_contribution, :id => request.id
      assert_response :redirect
      assert_redirected_to demande_path(request.id)
      assert flash.has_key?(:notice)
      assert !flash.has_key?(:warning)
    }
  end

  def test_print
    %w(admin manager expert customer viewer).each {|l|
      login l, l
      request_id = session[:user].contrats.first.demandes.first.id
      get :print, :id => request_id
      assert_response :success
      assert_template 'print'
    }
  end


  private
  def _test_ajax_form_methods
    # test the 3 ajax methods
    xhr :get, :ajax_display_commitment, :demande => { :severite_id => '2',
      :typedemande_id => '2' }
    assert_response :success

    xhr :get, :ajax_display_version, :demande => { :logiciel_id => "1",
      :socle_id => "1"}
    assert_response :success

    xhr :get, :ajax_display_contract, :contrat_id => session[:user].contrats.first.id
    assert_response :success
  end


end
