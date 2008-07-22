class ContractsController < ApplicationController
  helper :clients, :engagements, :ingenieurs

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
    @releases = @contract.releases.find(:all, :conditions => { :inactive => false })
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
    selected = params[:select]
    if selected.blank? || !selected.has_key?(:software)
      return render(:nothing => true)
    end
    @logiciel = Logiciel.find(selected[:software])
    @random_id = "s#{rand(10000)}_#{@logiciel.id}"
    render(:update) { |page|
      page.insert_html(:before, "end", :partial => "software")
      page.visual_effect(:appear, @random_id)
    }
  end

  def supported_software
    @contract = Contract.find(params[:id])
    @releases = @contract.releases
    @logiciels = Logiciel.find_select
  end

  # TODO : include version.packaged or not ?
  def add_software
    @contract = Contract.find(params[:id])
    new_release = []
    unless params['software'].nil?
      params['software'].each do |s|
        s = s[1] # access params which contain software informations
        if s['release_id'].blank? #create release
          release = Release.new
          release.contract_id = @contract.id
          release.logiciel_id = s['software']
          release.release = s['release']
          release.inactive = s['inactive'] == "on" ? 1 : 0
          # create or find the version
          version = Logiciel.find(s['software']).versions.find(:all, :conditions => ["version = ?", s['version'] ]).first
          version = Version.new if version.nil?
          version.version = s['version']
          version.logiciel_id = s['software']
          # save version and release
          version.save
          release.version = version
          release.save
          new_release.push release
        else #update release
          release = Release.find(s['release_id'])
          release.update_attributes :release => s['release'], :inactive => s['inactive'] == "on" ? 1 : 0
          new_release.push release
        end
      end
    end
    @contract.releases.each do |r|
      r.destroy unless new_release.include? r
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
