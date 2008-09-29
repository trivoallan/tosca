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
class CommentsController < ApplicationController
  helper :issues

  cache_sweeper :comment_sweeper, :only =>
    [:comment, :update, :destroy]
  # A comment is created only from the issue interface
  cache_sweeper :issue_sweeper, :only => [:comment]

  def index
    @comment_pages, @comments = paginate :comments,
    :per_page => 10, :include => [:issue]
  end

  def show
    @comment = Comment.find(params[:id])
    @issue = @comment.issue
  end

  #Used by the comment view of an issue to add one
  def comment
    comment, id = params[:comment], params[:id]
    return render(:nothing => true) unless id && comment

    user = session[:user]
    issue = Issue.find(id)

    # firewall ;)
    return render(:nothing => true) unless user && issue

    # check on attributes change
    # Find a way to put it in the model despite the access from issue view
    changed = {}
    %w{statut_id ingenieur_id severite_id}.each do |attr|
      changed[attr] = true unless comment[attr].blank?
    end
    if (changed[:statut_id] or changed[:severite_id]) and params[:comment][:private]
      params[:comment][:private] = false
      flash[:warn] = _("A comment can not be private if there is a change in<br/>
        the <b>status</b> or in the <b>severity</b>")
    end

    @comment = Comment.new(comment) do |c|
      c.issue, c.user = issue, user
      c.add_attachment(params)
    end

    issue.update_attribute :expected_on, Time.now if user.client?

    #We verify and send an email
    if @comment.save
      flash[:notice] = _("Your comment was successfully added.")
      url_attachment = render_to_string(:layout => false, :template => '/attachment')
      options = { :issue => issue, :comment => @comment,
        :name => user.name, :modifications => changed,
        :url_issue => issue_url(issue),
        :url_attachment => url_attachment
      }
      Notifier::deliver_issue_new_comment(options, flash)
    else
      flash[:warn] = _("An error has occured.") + '<br/>' +
        @comment.errors.full_messages.join('<br/>')
      flash[:old_body] = @comment.text
    end

    redirect_to issue_path(issue)
  end

  # We could only create a comment with comment method, from
  # issue view
  def new
    render :nothing => true
  end
  def create
    render :nothing => true
  end

  def edit
    @comment = Comment.find(params[:id])
    return if _not_allowed?
    # @comment.errors.clear
    _form
  end

  def update
    @comment = Comment.find(params[:id])
    return if _not_allowed?
    if @comment.update_attributes(params[:comment])
      flash[:notice] = _("The comment was successfully updated.")
      redirect_to comment_path(@comment)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    return redirect_to_home unless params[:id]
    comment = Comment.find(params[:id])
    issue = comment.issue_id
    if comment.destroy
      flash[:notice] = _("The comment was successfully destroyed.")
    else
      flash[:warn] = _('You cannot delete the first comment')
    end
    redirect_to issue_path(issue)
  end

  private
  def _form
    @issues = Issue.find(:all)
    @users = User.find_select
    @statuts = Statut.find_select
  end

  def _not_allowed?
    if @recipient and @comment.user_id != @recipient.user_id
      flash[:warn] = _('You are not allowed to edit this comment')
      redirect_to issue_path(@comment.issue)
      return true
    end
    false
  end
end
