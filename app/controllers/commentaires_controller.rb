#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CommentairesController < ApplicationController
  helper :demandes

  def index
    @commentaire_pages, @commentaires = paginate :commentaires,
    :per_page => 10, :include => [:demande]
  end

  def show
    @commentaire = Commentaire.find(params[:id])
  end

  #utilisé par la vue "comment" de Demande pour en ajouter un
  def comment
    unless params[:id] and params[:commentaire]
      return render_text('')
    end

    user = session[:user]
    demande = Demande.find(params[:id])

    modifications = {}
    if params[:commentaire]
      #on regarde si le statut a changer
      %w{statut_id ingenieur_id severite_id}.each do |attr|
        modifications[attr] = true unless params[:commentaire][attr].blank?
      end

      # auto-assignment to current engineer
      if demande.ingenieur_id.nil? and not @ingenieur.nil?
        demande.update_attribute :ingenieur_id, @ingenieur.id
      end
    else
      params[:commentaire] = {}
    end

    # public si on modifie le statut
    params[:commentaire][:prive] = false if modifications[:statut_id]
    # TODO : avertir ??
    # 'Le statut a été modifié : le commentaire est <b>public</b>'
    @commentaire = Commentaire.new(params[:commentaire])
    @commentaire.demande_id = demande.id
    if params[:piecejointe] and params[:piecejointe][:file] != ''
      @commentaire.piecejointe = Piecejointe.new(params[:piecejointe])
    end
    @commentaire.user_id = user.id

    # on vérifie et on envoie le courrier
    # TODO : Le validate dans le model commentaire ne semble pas fonctionner, voir pourquoi
    if @commentaire.corps.size < 5
      @commentaire.errors.add_on_empty('corps')
#       Il ne faut _PAS_ de .now dans ce warn. Il est renvoyé au
#       contrôleur des demandes.
      flash[:warn] = _("Your comment is too short, please rewrite it.")
    elsif @commentaire.save
      #rollback#
      flash[:notice] = _("Your comment was successfully added.")
      url_attachment = render_to_string(:layout => false, :template => '/attachment')
      options = { :demande => demande, :commentaire => @commentaire,
                  :nom => user.nom, :modifications => modifications,
                  :url_request => demande_url(demande),
                  :url_attachment => url_attachment
      }
      Notifier::deliver_request_new_comment(options, flash)
    else
      flash[:warn] = _("A conflict has occured.") + '<br />' + 
        _('Please refresh your browser and try again.')
      flash[:old_body] = @commentaire.corps
    end

    redirect_to( demande_path(demande) )
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
    _form
  end

  def update
    @commentaire = Commentaire.find(params[:id])
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
    options = { :select => 'id, name', :order => 'users.name ASC' }
    @users = User.find(:all, options)
    @statuts = Statut.find_select
  end
end
