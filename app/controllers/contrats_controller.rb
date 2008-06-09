class ContratsController < ApplicationController
  helper :clients,:engagements,:ingenieurs

  def index
    @contrat_pages, @contrats = paginate :contrats, :per_page => 25
  end

  # Used to know which contracts need to be renewed
  def actives
    options = { :per_page => 10, :include => [:client], :order =>
      'contrats.cloture', :conditions => 'clients.inactive = 0' }
    @contrat_pages, @contrats = paginate :contrats, options
    render :action => 'index'
  end


  def show
    @contrat = Contrat.find(params[:id])
    @teams = @contrat.teams
  end

  def new
    # It is the default contract
    @contrat = Contrat.new
    @contrat.client_id = params[:id]
    @contrat.rule_type = 'Rules::Component'
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
    Client.send(:with_exclusive_scope) do
      @contrat = Contrat.new(params[:contrat])
    end
    @contrat.creator = session[:user]
    if @contrat.save
      # TODO : now that we have the team notion, maybe we can remove this ?
      set_team_ossa
      flash[:notice] = _('Contract was successfully created.')
      redirect_to contrats_path
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contrat = Contrat.find(params[:id])
    _form
  end

  def update
    @contrat = Contrat.find(params[:id])
    @contrat.creator = session[:user] unless @contrat.creator
    if @contrat.update_attributes(params[:contrat])
      set_team_ossa
      flash[:notice] = _('Contrat was successfully updated.')
      redirect_to contrat_path(@contrat)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contrat.find(params[:id]).destroy
    redirect_to contrats_path
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
    @contract_team = @contrat.teams
    @rules = []
    begin
      @rules = @contrat.rule_type.constantize.find_select
    rescue Exception => e
      flash[:warn] = _('Unknown rules for contract "%s"') % e.message
    end
  end

  def set_team_ossa
    team = params[:team]
    if team and team[:ossa] == '1'
      team_ossa = Ingenieur.find_ossa(:all).collect{ |i| i.user }
      users = @contrat.engineer_users.dup.concat(team_ossa)
      users.uniq!
      @contrat.update_attribute :engineer_users, users
    end
  end
end
