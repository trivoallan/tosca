#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Raise errors beyond the default web-based presentation
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  
  fixtures :identifiants, :identifiants_roles, :roles, 
    :permissions_roles, :permissions, :clients
  
  def setup
    @controller = AccountController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_auth_bob

    post :login, :user_login => 'bob', :user_password => 'test',
      :user_crypt => 'false'

    assert @response.has_session_object?(:user)
    assert_equal @bob, @response.session["user"]
    assert_equal @response.redirect_url, 'http://localhost/'
  end
  
  def test_signup
    post :signup, {
      :client => { :id => 2},
      :identifiant => { 
        :login => 'newbob',
        :pwd => 'newpassword',
        :pwd_confirmation => 'newpassword'
      }
    }
    assert flash.has_key?(:notice)
    assert_response :success
    assert @response.has_session_object?(:user)
    
  end

  def test_bad_signup
#   @request.session['return-to'] = "/bogus/location"

    post :signup, 'identifiant' => { "login" => "newbob", 
      "password" => "newpassword", "password_confirmation" => "wrong" }
    #TODO : virer cette ligne obsolète
#   assert_invalid_column_on_record "user", "password"
    assert !flash.has_key?(:notice)
    assert_response :success
    assert find_record_in_template('user').errors.invalid?(:password)
    
    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "newpassword" }
#    assert_invalid_column_on_record "user", "login"
    assert(find_record_in_template(:user).errors.invalid?(:password)) 
    #TODO deprecated
    assert_success

    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "wrong" }
#    assert_invalid_column_on_record "user", ["login", "password"]
    assert(find_record_in_template(:user).errors.invalid?(:password)) 
    #TODO deprecated
    assert_success
  end

  def test_invalid_login
    post :login, "user_login" => "bob", "user_password" => "not_correct"
     
    assert !@response.has_session_object?(:user)
    
    #TODO : virer cette ligne obsolète
#   assert_template_has "message"
#    assert_template_has "login"
    assert @response.has_template_object?(:message)
    #assert @response.has_template_object?(:login)
  end
  
  def test_login_logoff

    post :login, :user_login => 'bob', :user_password => 'test',
      :user_crypt => 'false'
    assert @response.has_session_object?(:user)

    get :logout
    assert !@response.has_session_object?(:user)
  end
  
end
