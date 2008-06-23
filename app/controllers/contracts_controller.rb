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
    @paquets = @contract.paquets.find(:all, :conditions => { :active => 1 })
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
    if params[:software].blank?
      return render(:text => '')
    end
    @logiciel = Logiciel.find(params[:software])
    render(:update) { |page| page.insert_html(:before, "end", :partial => "contracts/logiciel") }
  end

  def area
    @contract = Contract.find(params[:id])
    @paquets = @contract.paquets
  end

  def add_softwares
    @contract = Contract.find(params[:id])
    @contract.paquets.each do |p|
      find = false
      unless params['softwares'].nil?
        params['softwares'].each do |s|
          if s[1]['paquet_id'].to_s == p.id.to_s
            find = true
            p.version = s[1]['version']
            p.active = s[1]['active'] == "on" ? 1 : 0
            p.save
          end
        end
      end
      if find == false
        p.destroy
      end
    end
    unless params['softwares'].nil?
      params['softwares'].each do |s|
        if s[1]['paquet_id'].blank?
          paquet = Paquet.new
          paquet.contract_id = @contract.id
          paquet.logiciel_id = s[1]['software']
          paquet.name = Logiciel.find(s[1]['software']).name
          paquet.version = s[1]['version']
          paquet.active = s[1]['active'] == "on" ? 1 : 0
          paquet.conteneur_id = 3
          paquet.configuration = ""
          paquet.save
        end
      end
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
