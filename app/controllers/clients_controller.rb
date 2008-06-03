class ClientsController < ApplicationController
  helper :demandes, :socles, :engagements, :contrats, :filters

  def index
    options = { :per_page => 10, :order => 'clients.name',
      :include => [:image] }

    if params.has_key? :filters
      session[:clients_filters] = Filters::Clients.new(params[:filters])
    end

    conditions = nil
    if session.data.has_key? :clients_filters
      clients_filters = session[:clients_filters]

      # Here is the trick for the "active" part of the view
      special_cond = _active_filters(clients_filters[:active])

      # we do not want an include since it's only for filtering.
      unless clients_filters['system_id'].blank?
        options[:joins] = 'INNER JOIN clients_socles ON clients_socles.client_id=clients.id'
      end

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(clients_filters, [
        [:text, 'clients.name', 'clients.description', :dual_like ],
        [:system_id, 'clients_socles.socle_id', :equal ]
      ], special_cond)
      @filters = clients_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @client_pages, @clients = paginate :clients, options

    # panel on the left side.
    if request.xhr?
      render :partial => 'clients_list', :layout => false
    else
      _panel
      @partial_for_summary = 'clients_info'
    end
  end

  def inactives
    active = 'clients.inactive = 1'
    options = { :per_page => 10, :order => 'clients.name',
      :include => [:image], :conditions => active }
    @client_pages, @clients = paginate :clients, options
    render :action => 'index'
  end

  def stats
    index
    @typedemandes = Typedemande.find(:all)
  end

  def show
    @client = Client.find(params[:id], :include => [:socles])
    # allows to see only binaries of this client for all without scope
    begin
      Binaire.set_scope(@client.contrat_ids) if @ingenieur
      render
    ensure
      Binaire.remove_scope if @ingenieur
    end
  end

  def new
    @client = Client.new
    _form
  end

  def create
    @client = Client.new(params[:client])
    if @client.save
      flash[:notice] = _('Client created successfully.') + '<br />' +
        _('You have now to create the associated contract.')
      redirect_to new_contrat_path(:id => @client.id)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @client = Client.find(params[:id])
    _form
  end

  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(params[:client])
      flash[:notice] = _('Client updated successfully.')
      redirect_to client_path(@client)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to clients_path
  end

  private
  def _form
    # only client picture.
    @images = Image.find_select(:order => "clients.name", :include => [:client],
      :conditions => 'images.logiciel_id IS NULL')
    # It's the only way to add new system to its own scope
    Socle.send(:with_exclusive_scope) do
      @socles = Socle.find_select
    end
  end

  def _panel
    @systems = Socle.find_select
  end

  # A small helper which set current flow filters
  # for index view
  def _active_filters(value)
    case value.to_i
    when -1
      @title = _('Inactive clients')
      'clients.inactive = 1'
    else # '1' & default are the same.
      @title = _('Active clients')
      'clients.inactive = 0'
    end
  end

end
