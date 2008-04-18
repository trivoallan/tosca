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
=end

  def test_should_be_able_to_create
    %w(admin manager expert customer).each {|l|
      login l, l
      get :new

      assert_response :success
      assert_template 'new'
      u = session[:user]

      form = select_form 'main_form'
      recipient = Beneficiaire.find(:first)
      contract = recipient.user.contrats.first
      p recipient
      p contract
      # Those values are different from the default one, despite what it seems
      fields = { :typedemande_id => 1, :severite_id => 1,
        :contrat_id => contract.id, :beneficiaire_id =>
        recipient.id, :ingenieur_id =>
        contract.engineer_users.first.ingenieur.id }

      p fields
      request = form.demande
      request.resume = "there is a prob with foo"
      request.description = "it's a bar"
      fields.each { |key, value|
        puts "#{u} #{key}"
        request.send(key).value = value if request.respond_to? key
      }
      form.submit

      assert_response :success
      p u
      p assigns(:demande)
      p assigns(:demande).errors.full_messages
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
