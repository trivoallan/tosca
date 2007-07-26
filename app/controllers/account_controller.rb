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

  skip_before_filter :login_required
  before_filter :login_required, :except => [:login]

  def index
    # init
    options = { :per_page => 15, :order => 'identifiants.login', :include =>
      [:beneficiaire,:ingenieur,:roles] }
    conditions = []
    @roles = Role.find_select

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    conditions = Filters.build_conditions(params, [
       ['identifiant', 'nom', 'identifiants.nom', :like ],
       ['filters', 'client_id', 'beneficiaires.client_id', :equal ],
       ['filters', 'role_id', 'identifiants_roles.role_id', :equal ]
     ])
    flash[:conditions] = options[:conditions] = conditions

    @user_pages, @users = paginate :identifiants, options
    # panel on the left side
    if request.xhr?
      render :partial => 'users_list', :layout => false
    else
      _panel
      @partial_for_summary = 'users_info'
    end
  end

  # NO_JAVASCRIPT = '<br/>Javascript n\'est pas activé sur votre navigateur'
  def login
    case request.method
      when :post
        if session[:user] = Identifiant.authenticate(params['user_login'],
                                                   params['user_password'],
                                                   params['user_crypt'])
          set_sessions
          flash[:notice] = _("Welcome&nbsp;%s&nbsp;%s") % 
            [ session[:user].titre, session[:user].nom.gsub(' ', '&nbsp;') ]
          redirect_to_home
        else
          flash.now[:warn]  = _("Connexion failure")
          redirect_to_home
        end
    end
  end

  # Let an Engineer become a client user
  def devenir
    if @ingenieur
      benef = Beneficiaire.find(params[:id])
      set_sessions benef.identifiant
    else
      flash[:warn] = _('Vous are not allowed to change your identity')
    end
    redirect_to_home
    return
  rescue ActiveRecord::RecordNotFound
    flash[:warn] = _('Person not found')
    redirect_to_home
  end

  def edit
    @identifiant = Identifiant.find(params[:id])
    _form
  end

  def show
    @identifiant = Identifiant.find(params[:id])
  end

  def update
    @identifiant = Identifiant.find(params[:id])
    if @identifiant.update_attributes(params[:identifiant])
      #On a sauve le profil, on l'applique sur l'utilisateur courant
      set_sessions  @identifiant if session[:user] == @identifiant
      flash[:notice]  = _("Edition succeeded")
      redirect_to account_path(@identifiant)
    end
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
        flash[:notice] = _('Record successfully created, don\'t forget to vérify his profil<br />')
        @identifiant.create_person(client)
        flash[:notice] << (@identifiant.client ?
                           _('Recipient') : _('Engineer ') << _(' associate created'))
        # welcome mail
        options = { :identifiant => @identifiant, :controller => self,
          :password => @identifiant.pwd }
        Notifier::deliver_identifiant_nouveau(options, flash)
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
      if(params['textarea_csv'].to_s.empty?)
        flash.now[:warn] = _('Enter under CSV format please')
      end
      COLUMNS.each { |key|
        unless row.include? key
          flash.now[:warn] = _('The CSV file isn\t well formed')
        end
      }
      if params[:identifiant].nil? or params[:identifiant][:client].nil?
        flash.now[:warn] = _('You don\'t have specified a customer')
      end
      if params[:identifiant][:role_ids].nil?
        flash.now[:warn] = _('Vous must specify a role')
      end

      return unless flash.now[:warn] == ''
      flash[:notice] = ''
      roles = Role.find(params[:identifiant][:role_ids])

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
        identifiant.roles = roles
        if identifiant.save
          client = Client.find(params[:client][:id])
          flash[:notice] += _("The user %s have been successfully created.<br/>") % row[_('Full name')]
          identifiant.create_person(client)
          flash[:notice] += (@identifiant.client ? _('Recipient') : _('Engineer ') +
            _('Associate created') )
          options = { :identifiant => identifiant, :controller => self,
            :password => row[_('Password')].to_s }
          Notifier::deliver_identifiant_nouveau(options, flash)
          flash[:notice] += '<br/>'
        else
          flash.now[:warn] += _('The user %s  has not been successfully created.<br /> ') %
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
  def set_sessions(identifiant = nil)
    return unless session[:user] or identifiant
    # clear_session erase session[:user]
    identifiant = session[:user] unless identifiant
    clear_sessions
    # Set user properties
    session[:user] = identifiant
    session[:beneficiaire] = session[:user].beneficiaire
    session[:ingenieur] = session[:user].ingenieur
    # Just to remember if javascript activated on client browser
    session[:javascript] = true
    # TODO : à intégrer de manière propre avec le SSO du portail
    # désactivé pour l'instant
    # ( params['javascript'] == "true" ? true : false )

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
         menu << (session[:user].authorized?('demandes') ? 'AAA<a class="no_hover">'+search_demande+'</a>' : nil )
         menu << public_link_to_softwares
         menu << public_link_to_contributions
         menu << link_to_admin
         menu << public_link_to_about
      %>
      <%= build_simple_menu(menu, :form => true) if session[:user] %>
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
      <%= build_simple_menu(infos.reverse, :class => 'account_menu') if session[:user] %>
    EOF
  end

  # Efface les paramètres de session et les raccourcis
  def clear_sessions
    reset_session
    @beneficiaire = nil
    @ingenieur = nil
  end

end
