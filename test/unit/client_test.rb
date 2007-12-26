#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase
  fixtures :clients, :images, :severites, :beneficiaires, :users, :contrats,
    :contributions, :logiciels, :ossas, :time_tickets

  def test_to_strings
    check_strings Client
  end

  def test_logo
    image_file = fixture_file_upload('/files/logo_linagora.gif', 'image/gif')
    client = Client.new(:name => "Linaragots")

    assert client.save

    images(:image_00001).destroy
    t = Image.new(:image => image_file, :client => client)
    t.id = 1
    t.save

    client = Client.find_by_name('Linaragots')
    assert !client.image.image.blank?
  end

  def test_destroy
    Client.find(:all).each {  |c|
      c.destroy
      assert Beneficiaire.find_all_by_client_id(c.id).empty?
      assert Document.find_all_by_client_id(c.id).empty?
    }
  end

  def test_desactivate_recipients
    Client.find(:all).each {  |c| c.desactivate_recipients }
  end

  def test_contrat_ids
    Client.find(:all).each { |c| check_ids c.contrat_ids, Contrat }
  end

  def test_support_distribution
    Client.find(:all).each { |c|
      res = c.support_distribution
      assert !res.nil?
      assert(res == true || res == false)

    }
  end

  def test_beneficiaire_ids
    Client.find(:all).each { |c| check_ids c.beneficiaire_ids, Beneficiaire }
  end

  def test_ingenieurs
    Client.find(:all).each{|c| c.ingenieurs.each{|i| assert i.is_a?(Ingenieur)}}
  end

  def test_logiciels
    Client.find(:all).each{|c| c.logiciels.each{|i| assert i.is_a?(Logiciel)}}
  end

  def test_contributions
    Client.find(:all).each{|c| c.contributions.each{|i| assert i.is_a?(Contribution)}}
  end

  def test_typedemandes
    Client.find(:all).each{|c| c.typedemandes.each{|i| assert i.is_a?(Typedemande)}}
  end

  def test_severites
    Client.find(:all).each{|c| c.severites.each{|i| assert i.is_a?(Severite)}}
  end

  def test_inactive
    Client.find(:all).each { |c|
      name = c.name
      c.update_attribute :inactive, true
      assert_equal c.name , "<strike>#{name}</strike>"
      c.beneficiaires.each do |b|
        assert b.user.inactive?
      end
    }
  end

end
