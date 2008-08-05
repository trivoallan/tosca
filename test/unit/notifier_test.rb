require File.dirname(__FILE__) + '/../test_helper'
require 'notifier'

class NotifierTest < Test::Unit::TestCase
  fixtures :users, :demandes
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "multipart", "alternative", { "charset" => CHARSET }
  end

  def test_user_signup
    user = User.find(:first)
    newpass = 'newpass'
    user.pwd = newpass
    response = Notifier::deliver_user_signup :user => user, :password => newpass
    assert_match /identifiant : #{user.login}/, response.body
    assert_match /mot de passe: #{newpass}/, response.body
    assert_equal user.email, response.to[0]
  end

  def test_request_new
    request = Demande.find(:first)
    options = { :demande => request, :name => request.submitter.name,
      :url_request => "www.request.com", :url_attachment => "www.attachment.com" }
    response = Notifier::deliver_request_new(options)
    assert_match request.resume, response.subject
    assert_match html2text(request.description), response.body
    assert_match options[:url_request], response.body
    assert_match options[:url_attachment], response.body
    assert_match options[:name], response.body
  end

  def test_request_new_comment
    request = Demande.find(:first)
    comment = request.first_comment
    options = { :demande => request, :name => request.submitter.name,
      :url_request => "www.request.com", :url_attachment => "www.attachment.com",
      :modifications => {:statut_id => true, :ingenieur_id => true, :severite_id => true},
      :commentaire => comment }
    response = Notifier::deliver_request_new_comment(options)
    assert_match request.resume, response.subject
    assert_match html2text(comment.corps), response.body
    assert_match options[:url_request], response.body
    assert_match options[:url_attachment], response.body
    assert_match options[:name], response.body
  end

  def test_welcome_idea
    user = User.find(:first)
    text = "this is an automated test suggestion"
    [:team,:tosca,:bullshit].each { |to|
      response = Notifier::deliver_welcome_idea(text, to, user)
      assert_match 'Suggestion', response.subject
      assert_match text, response.body
    }
  end

  private
  def encode(subject)
    quoted_printable(subject, CHARSET)
  end
end
