class TachesController < ApplicationController
  auto_complete_for :tache, :projet

  helper :ingenieurs, :projets

  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]

  def verifie
    super(Tache)
  end


  def auto_complete_for_tache_projet
    @projets = Projet.find(:all,
                       :conditions => [ 'LOWER(resume) LIKE ?',
                         '%' + params[:tache][:projet] + '%' ])
    render :inline => '<%= auto_complete_result(@projets, \'resume\') %>'
  end

  def auto_complete_for_tache_responsable
    auto_complete_responder_for_prestas params[:tache][:responsable]
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @tache_pages, @taches = paginate :taches, 
    :per_page => 10, :order => 'responsable_id ASC, position ASC'
    @duree_total = Tache.sum('duree', :conditions => "termine != 't'")
    @nombre_total = Tache.count(:all, :conditions => "termine != 't'")
  end

  def show
    @tache = Tache.find(params[:id])
  end

  def new
    @tache = Tache.new
    _form
  end

  # TODO : mettre ça en ajax, c'est un peu, beaucoup trop lent
  def move2bottom
    tache = Tache.find(params[:id])
    tache.move_to_bottom
    tache.save
    redirect_to :action => 'list'
  end

  def movehigher
    tache = Tache.find(params[:id])
    tache.move_higher
    tache.save
    redirect_to :action => 'list'
  end

  def movelower
    tache = Tache.find(params[:id])
    tache.move_lower
    tache.save
    redirect_to :action => 'list'
  end

  def move2top
    tache = Tache.find(params[:id])
    tache.move_to_top
    tache.save
    redirect_to :action => 'list'
  end

  def create
    _post(params)
    @tache = Tache.new(params[:tache])
     if @tache.save
      flash[:notice] = 'Tache was successfully created.'
      redirect_to :action => 'list'
    else
       _form
      render :action => 'new'
    end
  end

  def edit
    @tache = Tache.find(params[:id])
    _form
  end

  def update
    @tache = Tache.find(params[:id])
    _post(params)
    if @tache.update_attributes(params[:tache])
      flash[:notice] = 'Tache was successfully updated.'
      redirect_to :action => 'show', :id => @tache
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Tache.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private 
  def _form
    @etapes = Etape.find_all
  end

  def _post(params)
    # On retransforme en identifiant
    # C'est bien l'ajax, mais ça fait pas tout
    params[:tache][:responsable] = Ingenieur.find(
     :first, :include => [:identifiant],
     :conditions => ['nom=?', params[:tache][:responsable]])
    params[:tache][:projet] = Projet.find(:first, 
     :conditions => ['resume=?', params[:tache][:projet]])
    params[:tache][:auteur] = session[:user]

  end

  def auto_complete_responder_for_prestas(value)
    @prestas = Ingenieur.find_presta(:all, :include => [:identifiant],
                                     :conditions => 
                                       [ 'LOWER(identifiants.nom) LIKE ?',
                                       '%' + value.downcase + '%' ], 
                                     :order => 'identifiants.nom ASC',
                                     :limit => 8)
    render :partial => 'prestas'
  end

end
