class ContractsController < ApplicationController
  helper :clients,:engagements,:ingenieurs

  def index
    @contract_pages, @contracts = paginate :contracts, :per_page => 25
  end

  # Used to know which contracts need to be renewed
  def actives
    options = { :per_page => 10, :include => [:client], :order =>
      'contracts.cloture', :conditions => 'clients.inactive = 0' }
    @contract_pages, @contracts = paginate :contracts, options
    render :action => 'index'
  end


  def show
    @contract = Contract.find(params[:id])
    @versions = @contract.versions.find(:all, :conditions => { :active => 1 })
    @teams = @contract.teams
  end

  def new
    # It is the default contract
    @contract = Contract.new
    @contract.client_id = params[:id]
    @contract.rule_type = 'Rules::Component'
    _form
  end

  def ajax_choose
    value = params[:value]
    render :nothing => true and return unless request.xhr? && !value.blank?
    @rules = []
    if value.grep(/^Rules::/) # H@k3rz protection
      @rules = value.constantize.find_select
    end
    @type = 'rules' unless @rules.empty?
  end

  def create
    # It's needed because manager are scoped, at this point
    _aggregate_commitments
    Client.send(:with_exclusive_scope) do
      @contract = Contract.new(params[:contract])
    end
    @contract.creator = session[:user]
    if @contract.save
      flash[:notice] = _('Contract was successfully created.')
      redirect_to contracts_path
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contract = Contract.find(params[:id])
    _form
  end

  def update
    @contract = Contract.find(params[:id])
    @contract.creator = session[:user] unless @contract.creator
    _aggregate_commitments
    if @contract.update_attributes(params[:contract])
      flash[:notice] = _('Contract was successfully updated.')
      redirect_to contract_path(@contract)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contract.find(params[:id]).destroy
    redirect_to contracts_path
  end

  def ajax_add_software
    if params[:value].blank?
      return render(:nothing => true)
    end
    @logiciel = Logiciel.find(params[:value])
    render(:update) { |page| page.insert_html(:before, "end", :partial => "contracts/software") }
  end

  def supported_software
    @contract = Contract.find(params[:id])
    @versions = @contract.versions
    @logiciels = Logiciel.find_select
  end

  def add_software
    @contract = Contract.find(params[:id])
    new_version = []
    unless params['software'].nil?
      params['software'].each do |s|
        s = s[1] # access params which contain software informations
        if s['version_id'].blank? #create version
          version = Paquet.new
          version.contract_id = @contract.id
          version.logiciel_id = s['software']
          version.name = Logiciel.find(s['software']).name
          version.version = s['version']
          version.active = s['active'] == "on" ? 1 : 0
          version.conteneur_id = 3
          version.configuration = ""
          version.save
          new_version.push version
        else #update version
          version = Paquet.find(s['version_id'])
          version.update_attributes :version => s['version'], :active => s['active'] == "on" ? 1 : 0
          new_version.push version
        end
      end
    end
    @contract.versions.each do |p|
      p.destroy unless new_version.include? p
    end
    redirect_to contract_path(@contract)
  end

private
  def _form
    # Needed in order to be able to auto-associate with it
    Client.send(:with_exclusive_scope) do
      @clients = Client.find_select
    end
    @engagements = Engagement.find(:all, Engagement::OPTIONS)
    @ingenieurs = User.find_select(User::EXPERT_OPTIONS)
    @teams = Team.find_select
    @contract_team = @contract.teams
    @rules = []
    begin
      @rules = @contract.rule_type.constantize.find_select
    rescue Exception => e
      flash[:warn] = _('Unknown rules for contract "%s"') % e.message
    end
  end

  # Since Html lack of aggregation between multiple select, we have to do it
  # manually. It's a shame, and it's quite slow.
  # TODO : find a better way
  def _aggregate_commitments
    contract, ids = params[:contract], []
    return unless contract
    contract.keys.grep(/^engagement_ids/).each{|k|
      value = contract.delete(k)
      ids << value unless value == '0'
    }
    contract[:engagement_ids] = ids
  end

end
