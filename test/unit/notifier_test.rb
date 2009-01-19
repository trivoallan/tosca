#
# Copyright (c) 2006-2009 Linagora
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
require 'notifier'

class NotifierTest < Test::Unit::TestCase
  fixtures :users, :issues
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
    user = User.first(:order => :id)
    sender = users(:user_admin)
    newpass = 'newpass'
    user.pwd = newpass
    response = Notifier::deliver_user_signup(user)
    assert_match(/identifiant : #{user.login}/, response.body)
    assert_match(/mot de passe: #{newpass}/, response.body)
    assert_equal user.email, response.to[0]
  end

  def test_issue_new
    issue = Issue.first(:order => :id)
    response = Notifier::deliver_issue_new(issue)
    assert_match issue.resume, response.subject
    assert_match html2text(issue.description), response.body
    assert_match issue.submitter.name, response.body
  end

  def test_issue_new_comment
    issue = Issue.first(:order => :id)
    comment = issue.first_comment
    response = Notifier::deliver_issue_new_comment(comment)
    assert_match issue.resume, response.subject
    assert_match html2text(comment.text), response.body
    assert_match issue.submitter.name, response.body
  end

  def test_welcome_idea
    user = User.first(:order => :id)
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
