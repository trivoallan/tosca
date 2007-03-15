#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class InteractionsController < ApplicationController

  helper :demandes 

  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @interaction_pages, @interactions = paginate :interactions, 
    :per_page => 10, :include => [:logiciel]
  end

  def show
    @interaction = Interaction.find(params[:id])
  end

  def new
    @interaction = Interaction.new
    _form
  end

  def create
    @interaction = Interaction.new(params[:interaction])
    if @interaction.save 
      if params[:reversement]
        reversement = Reversement.new(params[:reversement])
        reversement.interaction = @interaction
        reversement.save
      end
      flash[:notice] = 'Interaction was successfully created.'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @interaction = Interaction.find(params[:id])
    _form
  end

  def update
    @interaction = Interaction.find(params[:id])
    if @interaction.update_attributes(params[:interaction])
      flash[:notice] = 'Interaction was successfully updated.'
      redirect_to :action => 'show', :id => @interaction
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Interaction.find(params[:id]).destroy
    redirect_to :action => 'list'
  end


  def ajax_update_reversement
    render_text '' and return unless request.xhr?
    if params[:action_reversement] == '1'
      @reversement = Reversement.new
      @contributions = Contribution.find_all
      @etatreversements = Etatreversement.find_all
    else
      @reversement = nil
    end
    # ajax, quand tu nous tiens ;)
    render :partial => 'form_reversement', :layout => false

  end

  private
  def _form
    @ingenieurs = Ingenieur.find_all
    @clients = Client.find_all
    @logiciels = Logiciel.find_all
    @reversement = @interaction.reversement if @interaction and @interaction.reversement
    # pour le formulaire partiel de reversement
    @contributions = Contribution.find_all
    @etatreversements = Etatreversement.find_all
  end

  def verifie
    super(Interaction)
  end

end
