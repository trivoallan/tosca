#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CommentairesController < ApplicationController
  helper :demandes

  cache_sweeper :commentaire_sweeper, :only => [:comment, :update, :destroy]

  def index
    @commentaire_pages, @commentaires = paginate :commentaires,
    :per_page => 10, :include => [:demande]
  end

  def show
    @commentaire = Commentaire.find(params[:id])
  end

  #utilisé par la vue "comment" de Demande pour en ajouter un
  def comment
    commentaire, id = params[:commentaire], params[:id]
    return render(:nothing => true) unless id && commentaire

    user = session[:user]
    request = Demande.find(id)

    changed = {}
    # check on attributes change
    %w{statut_id ingenieur_id severite_id}.each do |attr|
      changed[attr] = true unless commentaire[attr].blank?
    end

    # TODO : avertir ??
    # 'Le statut a été modifié : le commentaire est <b>public</b>'
    @comment = Commentaire.new(commentaire)
    @comment.add_attachment(params)

    # on vérifie et on envoie le courrier
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
      flash[:warn] = _("A conflict has occured.") + '<br />' +
        _('Please refresh your browser and try again.')
      flash[:old_body] = @comment.corps
    end

    redirect_to demande_path(request)
  end

  def changer_etat
    return render_text('') unless params[:id]
    @commentaire = Commentaire.find(params[:id])
    # toggle inverse un statut booleen
    if @commentaire.toggle!(:prive)
      flash[:notice] = _("The comment %s is now %s") % [ "##{@commentaire.id}", @commentaire.etat ]
    else
      flash.now[:warn] = _("An error has occured : The comment was not modified")
    end
    redirect_to comment_demande_path(@commentaire.demande_id)
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
    @commentaire.errors.clear
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
    redirect_to comment_demande_path(demande)
  end

  private
  def _form
    @demandes = Demande.find(:all)
    @users = User.find_select
    @statuts = Statut.find_select
  end

  def _not_allowed?
    if @beneficiaire and @commentaire.identifiant_id != @beneficiaire.identifiant_id
      flash[:warn] = _('You are not allowed to edit this comment')
      redirect_to demande_path(@commentaire.demande)
      return true
    end
    false
  end
end
