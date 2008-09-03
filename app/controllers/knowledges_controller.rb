class KnowledgesController < ApplicationController
  helper :filters


  def index
    options = { :per_page => 25, :order => 'knowledges.ingenieur_id',
      :include => [:ingenieur, :competence, :logiciel] }

    if params.has_key? :filters
      session[:knowledges_filters] =
        Filters::Knowledges.new(params[:filters])
    end
    conditions = nil
    knowledges_filters = session[:knowledges_filters]
    if knowledges_filters
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(knowledges_filters, [
        [:logiciel_id, 'knowledges.logiciel_id', :equal ],
        [:competence_id, 'knowledges.competence_id', :equal ],
        [:ingenieur_id, 'knowledges.ingenieur_id', :equal ]
      ])
      @filters = knowledges_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @knowledge_pages, @knowledges = paginate :knowledges, options
    if request.xhr?
      render :partial => 'knowledges_list', :layout => false
    else
      _panel
      @partial_for_summary = 'knowledges_info'
    end

  end

  def show
    @knowledge = Knowledge.find(params[:id])
  end

  def new
    @knowledge = Knowledge.new
    _form
  end

  def edit
    @knowledge = Knowledge.find(params[:id])
    _form
  end

  def create
    @knowledge = Knowledge.new(params[:knowledge])
    @knowledge.ingenieur_id = @ingenieur.id

    if @knowledge.save
      flash[:notice] = _('Your knowledge was successfully created.')
      redirect_to(account_path(@knowledge.ingenieur.user))
    else
      _form and render :action => "new"
    end
  end

  def update
    @knowledge = Knowledge.find(params[:id])
    if @knowledge.update_attributes(params[:knowledge])
      flash[:notice] = _('Your knowledge was successfully updated.')
      redirect_to(account_path(@knowledge.ingenieur.user))
    else
      _form and render :action => "edit"
    end
  end

  def destroy
    @knowledge = Knowledge.find(params[:id])
    @knowledge.destroy

    redirect_to(knowledges_url)
  end

  private
  def _form
    @competences = Competence.find_select
    @software = Logiciel.find_select
  end

  def _panel
    @software = Logiciel.find_select
    @competences = Competence.find_select
    @experts = Ingenieur.find_select(User::SELECT_OPTIONS)
  end

end
