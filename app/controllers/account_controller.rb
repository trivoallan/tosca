#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

class AccountController < ApplicationController
  # Pour l'import de plusieurs utilisateurs
  require 'fastercsv'

  # Auto completion in 2 lines, yeah !
  auto_complete_for :identifiant, :nom
  auto_complete_for :identifiant, :email

  helper :filters, :ingenieurs, :beneficiaires, :roles, :export

  before_filter :login_required, :except => [:login,:logout]
  around_filter :scope, :except => [:login, :logout]


  def index
    # init
    options = { :per_page => 15, :order => 'identifiants.login', :include =>
      [:beneficiaire,:ingenieur,:role] }
    conditions = []
    @roles = Role.find_select

    if params.has_key? :filters
      session[:accounts_filters] = Filters::Accounts.new(params[:filters])
    end
    conditions = nil
    if session.data.has_key? :accounts_filters
      accounts_filters = session[:accounts_filters]

      # Specification of a filter f :
      # [ namespace, field, database field, operation ]
      conditions = Filters.build_conditions(accounts_filters, [
        [:nom, 'identifiants.nom', :like ],
        [:client_id, 'beneficiaires.client_id', :equal ],
        [:role_id, 'identifiants.role_id', :equal ]
      ])
      flash[:conditions] = options[:conditions] = conditions
      @filters = accounts_filters
    end
    @user_pages, @users = paginate :identifiants, options
    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'users_list', :layout => false
    else
      _panel
      @partial_for_summary = 'users_info'
    end
  end

  # NO_JAVASCRIPT = '<br />Javascript n\'est pas activé sur votre navigateur'
  def login
    case request.method
      when :post
        user_crypt = 'false'
        user_crypt = params['user_crypt'] if params.has_key?('user_crypt')
        if session[:user] = Identifiant.authenticate(params['user_login'],
                                                     params['user_password'],
                                                     user_crypt)
          set_sessions(session[:user])
          flash[:notice] = _("Welcome&nbsp;%s&nbsp;%s") %
            [ session[:user].titre, session[:user].nom.gsub(' ', '&nbsp;') ]
          redirect_to_home
        else
          clear_sessions
          id = Identifiant.find_by_login(params['user_login'])
          flash.now[:warn] = _("Connexion failure")
          flash.now[:warn] << ", " << _("your account has been desactivated") if id and id.inactive?
        end
    end
  end

  # Let an Engineer become a client user
  def devenir
    if @ingenieur
      benef = Beneficiaire.find(params[:id])
      set_sessions(benef.identifiant)
    else
      flash[:warn] = _('You are not allowed to change your identity')
    end
    redirect_to_home
    return
  rescue ActiveRecord::RecordNotFound
    flash[:warn] = _('Person not found')
    redirect_to_home
  end

  def edit
    @identifiant = Identifiant.find(params[:id])
    @ingenieur = @identifiant.ingenieur
    @beneficiaire = @identifiant.beneficiaire
    _form
  end

  def show
    @identifiant = Identifiant.find(params[:id])
    @ingenieur = @identifiant.ingenieur
    @beneficiaire = @identifiant.beneficiaire
    _form
  end

  def update
    @identifiant = Identifiant.find(params[:id])
    @beneficiaire = @identifiant.beneficiaire
    @ingenieur = @identifiant.ingenieur

    # reset role when no case is selected
    params[:identifiant] = { :role_ids => [] } unless params.has_key? :identifiant

    unless ((@identifiant.update_attributes(params[:identifiant])) and
        ((not @beneficiaire) or
         @beneficiaire.update_attributes(params[:beneficiaire])) and
        ((not @ingenieur) or
         @ingenieur.update_attributes(params[:ingenieur])))
      _form and render :action => 'edit' and return
    end

    # we can changes roles in 'index' view
    index if request.xhr?

    #update cached profile for logged user
    set_sessions  @identifiant if session[:user] == @identifiant

    flash[:notice]  = _("Edition succeeded")
    redirect_to account_path(@identifiant)
  end

  def new
    redirect_to signup_new_account_path
  end

  # Create an account
  # Depending on if is a client, create related beneficiaire or engineer
  def signup
    _form
    case request.method
    when :post
      @identifiant = Identifiant.new(params['identifiant'])
      if @identifiant.save
        client = Client.find(params[:client][:id])
        flash[:notice] = _("Account successfully created, don't forget to check his profile.")
        @identifiant.create_person(client)
        flash[:notice] << (@identifiant.client ?
                           _('Recipient') : _('Engineer ') << _(' created'))
        # welcome mail
        options = { :identifiant => @identifiant, :controller => self,
          :password => @identifiant.pwd }
        Notifier::deliver_new_user(options, flash)
        redirect_back_or_default accounts_path
      end
    when :get
      @identifiant = Identifiant.new
    end
  end

  # Exit gracefully
  def logout
    clear_sessions
    redirect_to "/"
  end

  # Format du fichier CSV
  COLUMNS = [ _('Full name'), _('Title'), _('Email'), _('Phone'),
              _('Login'), _('Password'), _('Informations') ]

  # Bulk import users
  # TODO : fonction trop grosse.
  #  proposal : un chtit module qu'on inclu ?
  # Needs 'fastercsv'
  def multiple_signup
    _form
    @identifiant = Identifiant.new
    case request.method
    when :post
      if (params['textarea_csv'].to_s.empty?)
        flash.now[:warn] = _('Enter data under CSV format please')
      end
      COLUMNS.each { |key|
        unless row.include? key
          flash.now[:warn] = _('The CSV file is not correct')
        end
      }
      if !params.has_key? :identifiant or params[:identifiant][:client].blank?
        flash.now[:warn] = _('You have to specify a customer')
      end
      if !params.has_key? :identifiant or params[:identifiant][:role_ids].blank?
        flash.now[:warn] = _('Vous must specify a role')
      end

      return unless flash.now[:warn] == ''
      flash[:notice] = ''

      FasterCSV.parse(params['textarea_csv'].to_s.gsub("\t", ";"),
                      { :col_sep => ";", :headers => true }) do |row|
        identifiant = Identifiant.new do |i|
           logger.debug(row.inspect)
           i.nom = row[_('Full name')].to_s
           i.titre = row[_('Title')].to_s
           i.email = row[_('Email')].to_s
           i.telephone = row[_('Phone')].to_s
           i.login = row[_('Login')].to_s
           i.password = row[_('Password')].to_s
           i.password_confirmation = row[_('Password')].to_s
           i.informations = row[_('Informations')].to_s
           i.client = params[:identifiant][:client]
        end
        if identifiant.save
          client = Client.find(params[:client][:id])
          flash[:notice] += _("The user %s have been successfully created.<br />") % row[_('Full name')]
          identifiant.create_person(client)
          flash[:notice] += (@identifiant.client ? _('Recipient') : _('Engineer ') +
            _('Associate created') )
          options = { :identifiant => identifiant, :controller => self,
            :password => row[_('Password')].to_s }
          Notifier::deliver_new_user(options, flash)
          flash[:notice] += '<br />'
        else
          flash.now[:warn] += _('The user %s  has not been created.<br /> ') %
            identifiant.nom
        end

      end
      redirect_back_or_default accounts_path
    when :get
    end
  end

  # Destroy a user (via object)
  def destroy
    Identifiant.find(params[:id]).destroy
    redirect_to_home
  end


private
  # Partial variables used in forms
  def _form
    @roles = Role.find_select
    @clients = Client.find_select
    @competences = Competence.find_select
    @contrats = Contrat.find_select(Contrat::OPTIONS)
  end

  # Variables utilisé par le panneau de gauche
  def _panel
    @count = {}
    @clients = Client.find_select

    @count[:identifiants] = Identifiant.count
    @count[:beneficiaires] = Beneficiaire.count
    @count[:ingenieurs] = Ingenieur.count
  end

  # variable utilisateurs; nécessite session[:user]
  # penser à mettre à jour les pages statiques 404
  # et 500 en cas de modification
  # Le menu du layout est inclus pour des raisons de performances
  def set_sessions(identifiant)
    # clear_session erase session[:user]
    clear_sessions
    # Set user properties
    session[:user] = identifiant
    session[:beneficiaire] = session[:user].beneficiaire
    session[:ingenieur] = session[:user].ingenieur

    # Account links in header
    session[:account_links] = set_account_links
    # Navigation menu in header
    session[:menu] = set_menu
  end

  # Build the header menu
  def set_menu
    render_to_string :inline => <<-EOF
      <% menu = []
         menu << public_link_to_home
         menu << link_to_requests
         menu << (session[:user].authorized?('demandes/comment') ? '<a class="no_hover">'+search_demande+'</a>' : nil )
         menu << public_link_to_softwares
         menu << public_link_to_contributions
         menu << link_to_admin
         menu << public_link_to_about
      %>
      <%= build_simple_menu(menu, :form => true) %>
    EOF
    # for those who do want a complex menu
    #render_to_string :partial => 'menu'
  end

  # Build account links
  def set_account_links
    logout = _("Logout")
    my_account = _("My account")
    render_to_string :inline => <<-EOF
      <% infos = []
         infos << link_to("#{my_account}", edit_account_path(session[:user]))
         infos << public_link_to("#{logout}", logout_accounts_path, :method => :post)
      %>
      <%= build_simple_menu(infos.reverse, :class => 'account_menu') %>
    EOF
  end

  # Efface les paramètres de session et les raccourcis
  def clear_sessions
    @beneficiaire = nil
    @ingenieur = nil
    reset_session
  end

end
