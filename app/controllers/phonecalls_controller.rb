class PhonecallsController < ApplicationController
  helper :filters, :export, :demandes, :clients

  def index
    options = { :per_page => 15, :order => 'phonecalls.start', :include =>
      [:recipient,:ingenieur,:contract,:demande] }
    conditions = []

    if params.has_key? :filters
      session[:calls_filters] = Filters::Calls.new(params[:filters])
    end

    conditions = nil
    calls_filters = session[:calls_filters]
    if calls_filters
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(calls_filters, [
        [:ingenieur_id, 'phonecalls.ingenieur_id', :equal ],
        [:recipient_id, 'phonecalls.recipient_id', :equal ],
        [:contract_id, 'phonecalls.contract_id', :equal ],
        [:after, 'phonecalls.start', :greater_than ],
        [:before, 'phonecalls.end', :lesser_than ]
      ])
      @filters = calls_filters
      flash[:conditions] = options[:conditions] = conditions
    end

    @phonecall_pages, @phonecalls = paginate :phonecalls, options
    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'calls_list', :layout => false
    else
      _panel
      @partial_for_summary = 'calls_info'
    end
  end

  def create
    @phonecall = Phonecall.new(params[:phonecall])
    if @phonecall.save
      flash[:notice] = _('The call was successfully created.')
      request = @phonecall.demande
      redirect_to(request ? demande_path(request) : phonecalls_path)
    else
      _form and render :action => 'new'
    end
  end

  def show
    @phonecall = Phonecall.find(params[:id])
  end

  def new
    @phonecall = Phonecall.new
    @phonecall.ingenieur = @ingenieur
    @phonecall.demande_id = params[:id]
    _form
  end

  def edit
    @phonecall = Phonecall.find(params[:id])
    _form
  end

  def update
    @phonecall = Phonecall.find(params[:id])
    if @phonecall.update_attributes(params[:phonecall])
      flash[:notice] = _('The phone call has been updated.')
      request = @phonecall.demande
      redirect_to(request ? demande_path(request) : phonecalls_path)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Phonecall.find(params[:id]).destroy
    redirect_to phonecalls_url
  end

  def ajax_recipients
    return render(:nothing) unless request.xml_http_request?

    # la magie de rails est cassé pour la 1.2.2, en mode production
    # donc je dois le faire manuellement
    # TODO : vérifier pour les versions > 1.2.2 en _production_ (!)
    contract = Contract.find(params[:id])
    @recipients =
      contract.client.recipients.find_select(User::SELECT_OPTIONS)

    render :partial => 'select_recipients', :layout => false and return
  rescue ActiveRecord::RecordNotFound
    render :text => '-'
  end

  private
  def _form
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @contracts = Contract.find_select(Contract::OPTIONS)
    contract = @phonecall.contract || @contracts.first
    @recipients =
      contract.client.recipients.find_select(User::SELECT_OPTIONS)
  end

  # variables utilisé par le panneau de gauche
  def _panel
    @count = {}
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @contracts = Contract.find_select(Contract::OPTIONS)
    @recipients = Recipient.find_select(User::SELECT_OPTIONS)

    @count[:phonecalls] = Phonecall.count
    @count[:recipients] = Phonecall.count 'recipient_id', {}
    @count[:ingenieurs] = Phonecall.count('ingenieur_id', {})
    @count[:demandes] = Phonecall.count('demande_id', :distinct => true)
    diff = 'TIME_TO_SEC(TIMEDIFF(end,start))'
    @count[:somme] = Phonecall.sum(diff).to_i
    @count[:moyenne] = Phonecall.average(diff).to_i
  end

end
