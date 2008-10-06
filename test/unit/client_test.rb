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

class ClientTest < Test::Unit::TestCase
  fixtures :clients, :images, :severities, :recipients, :users, :contracts,
    :contributions, :softwares, :components, :credits

  def test_to_strings
    check_strings Client
  end

  def test_logo
    image_file = fixture_file_upload('/files/logo_linagora.gif', 'image/gif')
    client = Client.new(:name => "Testing logo",
      :creator => User.find(:first),
      :description => "I a client with a nice logo",
      :address => "I live next door")
    assert client.save

    images(:image_00001).destroy
    i = Image.new(:image => image_file, :client => client)
    i.id = 1
    i.save

    client = Client.find_by_name('Testing logo')
    assert_match(/logo_linagora.gif$/, client.image.image.to_s)
    client.destroy
  end

  def test_destroy
    Client.find(:all).each {  |c|
      c.destroy
      assert Recipient.find_all_by_client_id(c.id).empty?
      assert Document.find_all_by_client_id(c.id).empty?
    }
  end

  def test_desactivate_recipients
    Client.find(:all).each {  |c| c.desactivate_recipients }
  end

  def test_contract_ids
    Client.find(:all).each { |c| check_ids c.contract_ids, Contract }
  end

  def test_scope
    Client.set_scope([Client.find(:first).id])
    Client.find(:all)
    Client.remove_scope
  end

  def test_overloaded_find_select
    assert !Client.find_select.empty?
  end

  def test_support_distribution
    Client.find(:all).each { |c|
      res = c.support_distribution
      assert !res.nil?
      assert(res == true || res == false)
    }
  end

  def test_recipient_ids
    Client.find(:all).each { |c| check_ids c.recipient_ids, Recipient }
  end

  def test_ingenieurs
    Client.find(:all).each{|c| c.ingenieurs.each{|i| assert_instance_of(Ingenieur, i)}}
  end

  def test_softwares
    Client.find(:all).each{ |c| c.softwares.each{ |i| assert_instance_of(Software, i) } }
  end

  def test_contributions
    Client.find(:all).each{|c| c.contributions.each{|i| assert_instance_of(Contribution, i)}}
  end

  def test_typeissues
    Client.find(:all).each{|c| c.typeissues.each{|i| assert_instance_of(Typeissue, i)}}
  end

  def test_severities
    Client.find(:all).each{|c| c.severities.each{|i| assert_instance_of(Severity, i)}}
  end

  def test_inactive
    Client.find(:all).each { |c|
      name = c.name
      assert c.update_attribute(:inactive, true)
      assert_equal c.name , "<strike>#{name}</strike>"
      c.recipients.each do |b|
        assert b.user.inactive?
      end

      assert c.update_attribute(:inactive, false)
      assert_equal c.name , name
      # reload client, in order to avoid cache errors
      Client.find(c.id).recipients.each do |b|
        assert !b.user.inactive?
      end
    }
  end

  def test_content_columns
    columns = Client.content_columns.collect { |c| c.name }
    columns.sort!

    assert_equal(["access_code", "description", "name"], columns)
  end
  
end
