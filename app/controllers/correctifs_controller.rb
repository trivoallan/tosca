#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class CorrectifsController < ApplicationController

  model :contribution

  #helper :reversements, :demandes, :paquets, :binaires, :logiciels

  before_filter :verifie, :only => 
    [ :show, :update, :destroy ]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def verifie
    super(Correctif)
  end

  def index
    list
    render :action => 'list'
  end

  def list
    # @count = Correctif.count
    conditions = nil
    @logiciels = Logiciel.find(:all)
    @count = Contribution.count
    scope_filter do
      @correctif_pages, @correctifs = paginate :contributions, :per_page => 10
    end
  end

  def show
    @correctif = Contribution.find(params[:id])
  end

  def edit 
    return redirect_to :controller => 'contributions', 
                       :action => 'edit', :id => params[:id]
  end

end
