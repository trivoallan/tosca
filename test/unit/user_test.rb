#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  self.use_instantiated_fixtures  = true
  
  fixtures :users



    
  def test_auth  
    @bob = User.find_by_login('bob')
    assert_equal  @bob, User.authenticate("bob", "test")    
    assert_nil    User.authenticate("nonbob", "test")
  end


  def test_passwordchange
    @bob = User.find_by_login('bob')
    password = @bob.password
    @bob.pwd = @bob.pwd_confirmation = "nonbobpasswd"
    assert @bob.save
    assert_equal @bob, User.authenticate("bob", "nonbobpasswd")
    assert_nil   User.authenticate("bob", "longtest")
    assert_nil   User.authenticate("bob", "test")
    @bob.password = password
    assert @bob.save
    assert_equal @bob, User.authenticate("bob", "test")
    assert_nil   User.authenticate("bob", "nonbobpasswd")
        
  end
  
  def test_disallowed_passwords

    u = User.new(:role_id => 1)
    u.login = "nonbobby"

    u.pwd = u.pwd_confirmation = "tiny"
    assert !u.save     

    u.pwd = u.pwd_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save     
        
    u.pwd = u.pwd_confirmation = ""
    assert !u.save    
        
    u.pwd = u.pwd_confirmation = "bobby_secure_password"
    assert u.save     
    assert u.errors.empty?
    assert u.destroy

  end
  
  def test_bad_logins

    u = User.new(:role_id => 1)
    u.pwd = u.pwd_confirmation = "bobs_secure_password"

    u.login = "x"
    assert !u.save     
    assert u.errors.invalid?('login')
    
    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.errors.invalid?('login')

    u.login = ""
    assert !u.save
    assert u.errors.invalid?('login')

    u.login = "okbob"
    assert u.save  
    assert u.errors.empty?
      
  end


  def test_collision
    u = User.new
    u.login      = "existingbob"
    u.pwd = u.pwd_confirmation = "bobs_secure_password"
    assert !u.save
  end


  def test_create
    u = User.new(:role_id => 1)
    u.login      = "nonexistingbob"
    u.pwd = u.pwd_confirmation = "bobs_secure_password"
      
    assert u.save  
    assert u.destroy
  end
  
end
