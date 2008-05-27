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
  end

  #utilisé par la vue "comment" de Demande pour en ajouter un
  def comment
    commentaire, id = params[:commentaire], params[:id]
    return render(:nothing => true) unless id && commentaire

    user = session[:user]
    request = Demande.find(id)

    return render(:nothing => true) unless user && request


    changed = {}
    # check on attributes change
    %w{statut_id ingenieur_id severite_id}.each do |attr|
      changed[attr] = true unless commentaire[attr].blank?
    end

    # TODO : avertir ??
    # 'Le statut a été modifié : le commentaire est <b>public</b>'
    @comment = Commentaire.new(commentaire)
    @comment.demande, @comment.user = request, user
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
      flash[:warn] = _("An error has occured.") + '<br />' +
        @comment.errors.full_messages.join('<br />')
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
    if @beneficiaire and @commentaire.user_id != @beneficiaire.user_id
      flash[:warn] = _('You are not allowed to edit this comment')
      redirect_to demande_path(@commentaire.demande)
      return true
    end
    false
  end
end
