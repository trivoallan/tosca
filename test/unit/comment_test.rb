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

class CommentTest < Test::Unit::TestCase
  fixtures :comments, :issues, :users

  def test_to_strings
    check_strings Comment
  end

  # We ensure to call all the methods
  def test_helper_methods
    c = Comment.find :first
    c.state
    c.mail_id
    assert !c.add_attachment({})
    c.fragments
  end

  def test_create_comment
    c = Comment.new(:text => 'this is a comment',
                        :issue => Issue.find(:first),
                        :user => User.find(:first))
    assert c.save!
    c = Comment.new(:text => 'this is a comment',
                        :issue => Issue.find(:first),
                        :user => User.find(:first),
                        :private => false, :statut_id => 1)
    assert c.save!
    # cannot change privately the status
    c = Comment.new(:text => 'this is a comment',
                        :issue => Issue.find(:first),
                        :user => User.find(:first),
                        :private => true, :statut_id => 1)
    assert !c.save
    # cannot declare a comment without a issue
    c = Comment.new(:text => 'this is a comment',
                        :user => User.find(:first),
                        :private => true, :statut_id => 1)
    assert !c.save
  end

  # last call to destroy will cover the special case of update_status
  def test_update_status
    d = Issue.find(:first)
    d.comments.each { d.destroy }
  end
  
  def test_create_comment_without_text
    #Should not work
    Statut::NEED_COMMENT.each do |s|
      c = Comment.new(:text => "",
        :issue => Issue.find(:first),
        :user => User.find(:first),
        :private => false, :statut_id => s)
      assert_equal(false, c.save)
    end

    #Should work
    ([1,2,3,4,5,6,7,8] - Statut::NEED_COMMENT).each do |s|
      c = Comment.new(:text => "",
        :issue => Issue.find(:first),
        :user => User.find(:first),
        :private => false, :statut_id => s)
      assert c.save!
    end
  end

end
