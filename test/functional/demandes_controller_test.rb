require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
# class DemandesController; def rescue_action(e) raise e end; end
class DemandesControllerTest < ActionController::TestCase

  fixtures :demandes, :commentaires, :users, :contrats_users,
    :beneficiaires, :clients, :statuts, :ingenieurs, :severites,
    :logiciels, :socles, :clients_socles, :paquets, :permissions, :roles,
    :permissions_roles, :contrats, :contrats_engagements, :engagements,
    :piecejointes, :typedemandes


  def atest_pending
    %w(admin manager expert customer).each do |l|
      login l, l
      get :pending
      assert_response :success
      assert_template 'pending'
    end
  end

  def atest_index
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

  def atest_new
    %w(admin manager expert customer).each do |l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'
    end
  end
=begin
  def test_should_get_index
    %w(viewer customer expert manager admin).each { |l|
      login l, l

      get :index
      assert_response :success
      assert_not_nil assigns(:demandes)

      check_ajax_filter :severite_id, 2, :demandes
      check_ajax_filter :statut_id, 4, :demandes
      check_ajax_filter :typedemande_id, 1, :demandes
    }
  end

  def test_should_show_request
    login 'admin', 'admin'
    Demande.find(:all).each { |r|
      get :show, :id => r.id
      assert_response :success
    }

    login 'customer', 'customer'
    u = User.find_by_login('customer')
    Demande.find_all_by_beneficiaire_id(u.beneficiaire.id).each { |r|
      get :show, :id => r.id
      assert_response :success
    }
  end


   Parameters: {"commit"=>"Déposer cette demande", "demande"=>{"logiciel_id"=>"1",
      "ingenieur_id"=>"1", "beneficiaire_id"=>"1", "resume"=>"There is a problem",
      "severite_id"=>"1", "description"=>"<p>I have to fill the description</p>",
      "contrat_id"=>"1", "socle_id"=>"Linux", "mail_cc"=>"", "typedemande_id"=>"2"}
    , "action"=>"create", "controller"=>"demandes", "piecejointe"=>
    {"file_temp"=>"", "file"=>#<File:/home/mloiseleur/tmp/CGI.24290.12> }}

=end

    def test_should_be_able_to_create
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

=begin
  def test_should_be_able_to_update
    login 'admin', 'admin'
    Demande.find(:all).each { |r|
      get :edit, :id => r.id

      assert_response :success
      assert_template 'edit'

      assert_not_nil assigns(:demande)
      assert assigns(:demande).valid?

      form = select_form 'main_form'
      form.demande.resume = "foo bar"
      form.submit

      assert_response :redirect
      assert_redirected_to :action => 'show', :controller => 'demandes'
      assert assigns(:demande).errors.empty?
    }
  end


  def test_should_be_able_to_print
    %w(admin manager expert customer viewer).each {|l|
      login l, l
      Demande.find(:all).each {|r|
        get :print, :id => r.id
        assert_response :success
        assert_template 'print'
        assert assigns(:demande).errors.empty?
      }
    }
  end
=end

end
