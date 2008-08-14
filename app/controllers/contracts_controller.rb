class ContractsController < ApplicationController
  helper :clients, :commitments, :ingenieurs, :versions

  def index
    @contract_pages, @contracts = paginate :contracts, :per_page => 25
  end

  # Used to know which contracts need to be renewed
  def actives
    options = { :per_page => 10, :include => [:client], :order =>
      'contracts.end_date', :conditions => 'clients.inactive = 0' }
    @contract_pages, @contracts = paginate :contracts, options
    render :action => 'index'
  end

  def show
    @contract = Contract.find(params[:id])
    @teams = @contract.teams
    @versions = @contract.versions
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
    _aggregate_commitments
    # It's needed because manager are scoped, at this point
    Client.send(:with_exclusive_scope) do
      @contract = Contract.new(params[:contract])
    end
    @contract.creator = session[:user]
    # Due to a limitation of Rails <= 2.1, we cannot create a full
    # association in one pass.
    # TODO : review this problem on a > Rails
    engineers =  @contract.engineer_users.dup
    @contract.engineer_users = []
    if @contract.save
      @contract.update_attribute :engineer_users, engineers
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
    selected = params[:select]
    if selected.blank? || !selected.has_key?(:software)
      return render(:nothing => true)
    end
    @logiciel = Logiciel.find(selected[:software])
    render(:update) { |page|
      page.insert_html(:before, "end", :partial => "software")
      page.visual_effect(:appear, @random_id)
    }
  end

  def supported_software
    @contract = Contract.find(params[:id])
    @versions = @contract.versions
    @logiciels = Logiciel.find_select
  end

  # TODO : include version.packaged or not ?
  def add_software
    @contract = Contract.find(params[:id])
    redirect_to contract_path(@contract)
    software = params['software']
    return unless software
    software.each do |s|
      # get rid of the random_field hack
      s = s[1]
      next unless s.is_a? Hash
      # It's 2 lines but fast find_or_create call
      version = Version.find(:first, :conditions => s)
      version = Version.create(s) unless version
      unless version.contract_ids.include?(@contract.id)
        version.contracts << @contract
      end
      version.save
    end
  end

private
  def _form
    # Needed in order to be able to auto-associate with it
    Client.send(:with_exclusive_scope) do
      @clients = Client.find_select
    end
    @commitments = Commitment.find(:all, Commitment::OPTIONS)
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
    contract.keys.grep(/^commitment_ids/).each{|k|
      value = contract.delete(k)
      ids << value unless value == '0'
    }
    contract[:commitment_ids] = ids
  end

end
