#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  self.use_instantiated_fixtures  = true

  fixtures :users, :clients, :roles, :permissions, :permissions_roles,
    :contracts_users, :contracts, :socles

  def test_to_strings
    check_strings User
  end

  def test_scope
    assert !User.get_scope([Contract.find(:first).id]).empty?
  end

  def test_reset_permission_strings
    User.reset_permission_strings
  end

  def test_team_manager
    User.find(:all).each { |u| u.team_manager? }
  end

  def test_find_select
    assert !User.find_select().empty?
  end

  def test_authenticate
    %w(admin manager expert customer viewer).each do |u|
      assert User.authenticate(u, u)
      assert_nil User.authenticate(u, 'a wrong password')
    end
  end

  def test_generate_password
    User.find(:all).each do |u|
      u.generate_password
      assert u.save
    end
  end

  def test_create_person
    u = User.new(:role_id => 1, :login => "newu", :email => "foo@bar.com",
                 :name => "foo",
                 :informations => "Somme infos")
    u.generate_password
    assert u.save

    c = clients(:client_00001)
    u.associate_recipient(c.id)
    assert u.recipient
    assert_equal u.recipient.client, c
    assert_equal u.client?, true

    u.associate_engineer
    assert u.ingenieur
    assert_equal u.client, false
  end

  def test_authorized
    customer = users(:user_customer)
    manager  = users(:user_manager)

    assert customer.authorized?('issues/show')
    assert manager.authorized?('issues/show')

    assert !customer.authorized?('contributions/edit')
    assert manager.authorized?('contributions/edit')
  end

  def test_contract_ids
    User.find(:all).each{ |u| check_ids u.contract_ids, Contract }
  end

  def test_client_ids
    User.find(:all).each{ |u| check_ids u.client_ids, Client }
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
    u = User.new(:role_id => 1, :email => "foo@bar.com",
                 :name => "foo",
                 :informations => "Some infos")
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
    u = User.new(:role_id => 1, :email => "foo@bar.com",
                 :name => "foo",
                 :informations => "Some infos")
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
    u = User.new(:role_id => 1, :email => "foo@bar.com",
                 :name => "foo")
    u.login = "admin"
    u.generate_password
    assert !u.save
  end

  def test_manager?
    viewer = users(:user_viewer)
    customer = users(:user_customer)
    expert = users(:user_expert)
    manager  = users(:user_manager)
    admin = users(:user_admin)

    assert_equal(viewer.manager?, false)
    assert_equal(customer.manager?, false)
    assert_equal(expert.manager?, false)
    assert_equal(manager.manager?, true)
    assert_equal(admin.manager?, true)
  end

  def test_kind
    viewer = users(:user_viewer)
    customer = users(:user_customer)
    expert = users(:user_expert)
    manager  = users(:user_manager)
    admin = users(:user_admin)

    kind_expert = 'expert'
    kind_recipient = 'recipient'

    assert_equal(viewer.kind, kind_recipient)
    assert_equal(customer.kind, kind_recipient)
    assert_equal(expert.kind, kind_expert)
    assert_equal(manager.kind, kind_expert)
    assert_equal(admin.kind, kind_expert)
  end
end
