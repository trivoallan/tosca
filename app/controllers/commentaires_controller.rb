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
class CommentairesController < ApplicationController
  helper :demandes

  cache_sweeper :commentaire_sweeper, :only =>
    [:comment, :update, :destroy]
  # A comment is created only from the request interface
  cache_sweeper :demande_sweeper, :only => [:comment]

  def index
    @commentaire_pages, @commentaires = paginate :commentaires,
    :per_page => 10, :include => [:demande]
  end

  def show
    @commentaire = Commentaire.find(params[:id])
    @demande = @commentaire.demande
  end

  #Used by the comment view of a request to add one
  def comment
    commentaire, id = params[:commentaire], params[:id]
    return render(:nothing => true) unless id && commentaire

    user = session[:user]
    request = Demande.find(id)

    # firewall ;)
    return render(:nothing => true) unless user && request

    # check on attributes change
    # Find a way to put it in the model despite the access from request view
    changed = {}
    %w{statut_id ingenieur_id severite_id}.each do |attr|
      changed[attr] = true unless commentaire[attr].blank?
    end
    if (changed[:statut_id] or changed[:severite_id]) and params[:commentaire][:prive]
      params[:commentaire][:prive] = false
      flash[:warn] = _("A comment can not be private if there is a change in<br/>
        the <b>status</b> or in the <b>severity</b>")
    end

    @comment = Commentaire.new(commentaire) do |c|
      c.demande, c.user = request, user
      c.add_attachment(params)
    end

    request.update_attribute :expected_on, Time.now if user.client?

    #We verify and send an email
    if @comment.save
      flash[:notice] = _("Your comment was successfully added.")
      url_attachment = render_to_string(:layout => false, :template => '/attachment')
      options = { :demande => request, :commentaire => @comment,
        :name => user.name, :modifications => changed,
        :url_request => demande_url(request),
        :url_attachment => url_attachment
      }
      Notifier::deliver_request_new_comment(options, flash)
    else
      flash[:warn] = _("An error has occured.") + '<br/>' +
        @comment.errors.full_messages.join('<br/>')
      flash[:old_body] = @comment.corps
    end

    redirect_to demande_path(request)
  end

  # We could only create a comment with comment method, from
  # request view
  def new
    render :nothing => true
  end
  def create
    render :nothing => true
  end

  def edit
    @commentaire = Commentaire.find(params[:id])
    return if _not_allowed?
    # @commentaire.errors.clear
    _form
  end

  def update
    @commentaire = Commentaire.find(params[:id])
    return if _not_allowed?
    if @commentaire.update_attributes(params[:commentaire])
      flash[:notice] = _("The comment was successfully updated.")
      redirect_to commentaire_path(@commentaire)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    return redirect_to_home unless params[:id]
    commentaire = Commentaire.find(params[:id])
    demande = commentaire.demande_id
    if commentaire.destroy
      flash[:notice] = _("The comment was successfully destroyed.")
    else
      flash[:warn] = _('You cannot delete the first comment')
    end
    redirect_to demande_path(demande)
  end

  private
  def _form
    @demandes = Demande.find(:all)
    @users = User.find_select
    @statuts = Statut.find_select
  end

  def _not_allowed?
    if @recipient and @commentaire.user_id != @recipient.user_id
      flash[:warn] = _('You are not allowed to edit this comment')
      redirect_to demande_path(@commentaire.demande)
      return true
    end
    false
  end
end
