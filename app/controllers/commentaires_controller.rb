#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CommentairesController < ApplicationController
  helper :demandes

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update ],
         :redirect_to => { :action => :list }
  def list
    @commentaire_pages, @commentaires = paginate :commentaires, 
    :per_page => 10, :include => [:demande]
  end

  def show
    @commentaire = Commentaire.find(params[:id])
  end

  #utilisé par la vue "comment" de Demande pour en ajouter un
  def comment
    unless params[:id] and params[:demande] and params[:commentaire]
      return render_text('') 
    end

    user = @session[:user]
    demande = Demande.find(params[:id])

    if params[:demande]
      # on regarde si le statut a changer
      statut_modifie = true if params[:demande][:statut_id] != ''
      params[:demande][:statut_id] = demande.statut_id unless statut_modifie
      # à la 'prise en compte' : assignation auto à l'ingénieur
      if params[:demande][:statut_id] == '2' and demande.ingenieur_id.nil?
        demande.ingenieur_id = @ingenieur.id
      end
    end

    # public si on modifie le statut
    params[:commentaire][:prive]=false if statut_modifie
    # TODO : avertir ??  
    # 'Le statut a été modifié : le commentaire est <b>public</b>' 
    @commentaire = Commentaire.new(params[:commentaire])
    @commentaire.demande_id = demande.id 
    if params[:piecejointe] and params[:piecejointe][:file] != ''
      @commentaire.piecejointe = Piecejointe.new(params[:piecejointe]) 
    end
    @commentaire.identifiant_id = user.id

    # on vérifie et on envoie le courrier
    if @commentaire.corps.size < 5
      @commentaire.errors.add_on_empty('corps') 
      # Il ne faut _PAS_ de .now dans ce warn. Il est renvoyé au 
      # contrôleur des demandes.
      flash[:warn] = 'Votre commentaire est trop court, veuillez recommencer'
    elsif @commentaire.save and demande.update_attributes(params[:demande])
      flash[:notice] = 'Le commentaire a bien été ajouté.'
      unless @commentaire.prive
        options = {:demande => demande, :commentaire => @commentaire, 
           :nom => user.nom, :controller => self,
           :request => @request, :statut_modifie => statut_modifie,
           :statut => demande.statut.nom }
        Notifier::deliver_demande_nouveau_commentaire(options, flash)
      end
    else
      flash[:warn] = 'Votre commentaire n\'a pas été ajouté correctement'
    end

    options = { :action => 'comment', :controller => 
      'demandes', :id => demande }
    redirect_to(url_for(options))
  end

  def changer_etat
    return render_text('') unless params[:id]
    @commentaire = Commentaire.find(params[:id])
    # toggle inverse un statut booleen
    if @commentaire.toggle!(:prive)
      flash[:notice] = "Le commentaire ##{@commentaire.id} est désormais #{@commentaire.etat}"
    else
      flash.now[:warn] = 'Une erreur s\'est produite : le commentaire n\'a pas été modifié"'
    end
    redirect_to :controller => 'demandes', :action => 
      'comment', :id => @commentaire.demande_id
  end

  def new
    @commentaire = Commentaire.new
    _form
  end

  def create
    @commentaire = Commentaire.new(params[:commentaire])
    if @commentaire.save
      flash[:notice] = 'Le commentaire a bien été crée.'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @commentaire = Commentaire.find(params[:id])
    _form
  end

  def update
    @commentaire = Commentaire.find(params[:id])
    if @commentaire.update_attributes(params[:commentaire])
      flash[:notice] = 'Commentaire was successfully updated.'
      redirect_to :action => 'show', :id => @commentaire
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    return redirect_to(:action => 'list', :controller => 'bienvenue') unless params[:id]
    commentaire = Commentaire.find(params[:id])
    demande = commentaire.demande_id
    commentaire.destroy
    flash[:notice] = 'Le commentaire a bien été supprimé.'
    redirect_to(:action => 'comment', :controller => 'demandes')
  end

  private
  def _form
    @demandes = Demande.find(:all)
    @identifiants = Identifiant.find_select
    @statuts = Statut.find_select
  end
end
