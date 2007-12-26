#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  self.use_instantiated_fixtures  = true

  fixtures :users, :clients, :roles

  def test_to_strings
    check_strings User
  end

  def test_authenticate
    %w(admin manager expert customer viewer).each { |u|
      assert User.authenticate(u, u)
      assert !User.authenticate(u, 'a wrong password')
    }
  end

  def test_create_person
    u = User.create(:role_id => 1, :login => "newu",
                    :pwd => 'newpass', :pwd_confirmation => 'newpass')
    c = clients(:client_00001)
    assert u.errors.empty?

    u.create_person(c)
    assert u.beneficiaire
    assert_equal u.beneficiaire.client, c
    assert_equal u.client, true

    u.create_person(nil)
    assert u.ingenieur
    assert_equal u.client, false
  end

  def test_authorized
    customer = users(:user_00004)
    manager  = users(:user_00002)

    assert customer.authorized?('demandes/comment')
    assert manager.authorized?('demandes/comment')

    assert !customer.authorized?('contributions/edit')
    assert manager.authorized?('contributions/edit')
  end

  def test_passwordchange
    @customer = User.find_by_login('customer')
    password = @customer.password
    @customer.pwd = @customer.pwd_confirmation = "noncustomerpasswd"
    assert @customer.save
    assert_equal @customer, User.authenticate("customer", "noncustomerpasswd")
    assert_nil   User.authenticate("customer", "longtest")
    assert_nil   User.authenticate("customer", "test")
    @customer.password = password
    assert @customer.save
    assert_equal @customer, User.authenticate("customer", "customer")
    assert_nil   User.authenticate("customer", "noncustomerpasswd")

  end

  def test_disallowed_passwords
    u = User.new(:role_id => 1)
    u.login = "nobody"

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
    u.pwd = u.pwd_confirmation = "a_very_secure_password"

    [ "x",  "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug", "" ].each { |p|
      u.login = p
      assert !u.save
      assert u.errors.invalid?('login')
    }

    u.login = "valid"
    assert u.save
    assert u.errors.empty?
  end


  def test_login_collision
    u = User.new
    u.login = "admin"
    u.pwd = u.pwd_confirmation = "very_secure_password"
    assert !u.save
  end
end
