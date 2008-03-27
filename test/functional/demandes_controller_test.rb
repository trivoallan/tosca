require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
# class DemandesController; def rescue_action(e) raise e end; end
class DemandesControllerTest < ActionController::TestCase

  fixtures :demandes, :commentaires, :users, :contrats_users,
    :beneficiaires, :clients, :statuts, :ingenieurs, :severites,
    :logiciels, :socles, :clients_socles, :paquets, :permissions, :roles,
    :permissions_roles, :contrats, :contrats_engagements, :engagements,
    :piecejointes, :typedemandes


  def setup
    login 'admin', 'admin'
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
=end
  def test_should_be_able_to_create
    %w(admin manager expert customer).each {|l|
      login l, l
      get :new

      assert_response :success
      assert_template 'new'
      u = session[:user]

      form = select_form 'main_form'
      # Those values are different from the default one, despite what it seems
      fields = { :typedemande_id => 1, :severite_id => 1,
        :contrat_id => u.contrats.first.id, :beneficiaire_id => 1, :ingenieur_id => 3 }

      form.demande.resume = "there is a prob with foo"
      form.demande.description = "it's a bar"
      fields.each { |key, value| p key; form.demande.send(key).value = value }
      form.submit

      assert_response :redirect
      assert_template 'attachment'
      assert assigns(:demande).errors.empty?
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
