#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Raise errors beyond the default web-based presentation
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  
  fixtures :identifiants, :identifiants_roles, :roles, 
    :permissions_roles, :permissions
  
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
    @request.session['return-to'] = "/bogus/location"

    post :signup, "user" => { "login" => "newbob", "password" => "newpassword",
      "password_confirmation" => "newpassword"
    }
    assert @response.has_session_object?(:user)
    
    #TODO vire cette ligne obsolète
    assert_redirect_url "/bogus/location"
  end

  def test_bad_signup
    @request.session['return-to'] = "/bogus/location"

    post :signup, "user" => { "login" => "newbob", "password" => "newpassword",
      "password_confirmation" => "wrong" }
    #TODO : virer cette ligne obsolète
#   assert_invalid_column_on_record "user", "password"
    assert find_record_in_template('user').errors.invalid?(:password)
    assert_success
    
    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "newpassword" }
#    assert_invalid_column_on_record "user", "login"
    assert(find_record_in_template(:user).errors.invalid?(:password)) 
    assert_success

    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "wrong" }
#    assert_invalid_column_on_record "user", ["login", "password"]
    assert(find_record_in_template(:user).errors.invalid?(:password)) 
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
