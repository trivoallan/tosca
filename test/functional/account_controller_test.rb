#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Raise errors beyond the default web-based presentation
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  
  fixtures :identifiants, :roles, :permissions_roles, :permissions, :clients
  
  def setup
    @controller = AccountController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end


  def test_index
    login 'admin', 'admin'
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:users)

    #test the ajax filters :
    get :index, :filters => { :client_id => 1 }
    assert_response :success
    assigns(:users).each { |u| assert_equal u.beneficiaire.client_id, 1 }

    get :index, :filters => { :role_id => 1 }
    assert_response :success
    assigns(:users).each { |u| assert_equal u.role_id, 1 }
  end
  
  def test_auth_bob

    post :login, :user_login => 'bob', :user_password => 'test',
      :user_crypt => 'false'

    assert @response.has_session_object?(:user)
    assert_equal @bob, @response.session["user"]
    assert_equal @response.redirect_url, 'http://localhost/bienvenue'
  end
  
  def test_signup
    post :login, :user_login => 'bob', :user_password => 'test',
      :user_crypt => 'false'
    post :signup, {
      :client => { :id => 2},
      :identifiant => { 
        :login => 'newbob',
        :email => 'mloiseleur@linagora.com',
        :pwd => 'newpassword',
        :pwd_confirmation => 'newpassword',
        :role_id => 2 # client role
      }
    }
    assert flash.has_key?(:notice)
    assert_redirected_to :action => 'index'
    assert @response.has_session_object?(:user)
    
  end

  def test_bad_signup
    num_identifiant = Identifiant.count
    post :login, :user_login => 'bob', :user_password => 'test',
      :user_crypt => 'false'

    post :signup, 'identifiant' => { "login" => "newbob", 
      "pwd" => "newpassword", "pwd_confirmation" => "wrong" }
    assert !flash.has_key?(:notice)
    assert_response :success
#   assert find_record_in_template('user').errors.invalid?(:pwd)
    assert_equal num_identifiant, Identifiant.count
    
    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "newpassword" }
#   assert(find_record_in_template(:user).errors.invalid?(:password)) 
    assert_response :success
    assert_equal num_identifiant, Identifiant.count

    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "wrong" }
#   assert(find_record_in_template(:user).errors.invalid?(:password)) 
    assert_response :success
    assert_equal num_identifiant, Identifiant.count
  end

  def test_invalid_login
    post :login, "user_login" => "bob", "user_password" => "not_correct"
     
    assert !@response.has_session_object?(:user)
    assert flash
    
#   assert @response.has_template_object?(:message)
#   assert @response.has_template_object?(:login)
  end
  
  def test_login_logoff

    post :login, :user_login => 'bob', :user_password => 'test',
      :user_crypt => 'false'
    assert @response.has_session_object?(:user)

    get :logout
    assert !@response.has_session_object?(:user)
  end
  
end
