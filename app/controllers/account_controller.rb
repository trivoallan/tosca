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
    list
    render :action => 'list'
  end
 
  # NO_JAVASCRIPT = '<br/>Javascript n\'est pas activé sur votre navigateur'
  def login
    case request.method
      when :post
      if session[:user] = Identifiant.authenticate(params['user_login'],
                                                   params['user_password'],
                                                   params['user_crypt'])
        set_sessions
        flash[:notice] = _("Bienvenue&nbsp;#{session[:user].titre}&nbsp;#{session[:user].nom.gsub(' ', '&nbsp;')}")
        # flash[:notice] << NO_JAVASCRIPT unless session[:javascript]
        redirect_to_home
      else
        flash.now[:warn]  = "Echec lors de la connexion"
      end
    end
  end

  # Let an Engineer become a client user
  def devenir
    if @ingenieur
      benef = Beneficiaire.find(params[:id])
      set_sessions benef.identifiant
    else
      flash[:warn] = 'Vous n\'êtes pas autoriser à changer d\'identité'
    end
    redirect_to_home
    return
  rescue ActiveRecord::RecordNotFound
    flash[:warn] = 'Personne inexistante'
    redirect_to_home
  end

  def modify
    _form
    case request.method
    when :post
      @identifiant = Identifiant.find(params[:id])
      newIdentifiant = params[:identifiant]
      #on ne met pas à jour le mot de passe
      if newIdentifiant[:password] == ''
        newIdentifiant[:password] = @identifiant.password
        newIdentifiant[:password_confirmation] = @identifiant.password
      else
        if newIdentifiant[:password] != newIdentifiant[:password_confirmation]
          flash[:notice] = 'Les mots de passe que avez entrés sont différents.'
          redirect_to :action => 'modify', :controller => 'account'
        else
          @identifiant.change_password(newIdentifiant[:password])
          newIdentifiant[:password] = @identifiant.password
        end
      end

      if @identifiant.update_attributes(newIdentifiant)
        #On a sauve le profil, on l'applique sur l'utilisateur courant
        set_sessions  @identifiant if session[:user] == @identifiant
        flash[:notice]  = "Modification réussie"
        redirect_back_or_default :action => '', :controller => 'bienvenue'
      end
    when :get
      @identifiant = Identifiant.find(params[:id])
      @identifiant.password_confirmation = @identifiant.password
    end
  end

  def show
    @identifiant = Identifiant.find(params[:id])
  end

  #utilisé dans account/list
  def update
    @user = Identifiant.find(params[:id])
    if @user.update_attributes(params[:identifiant])
      flash[:notice] = "L'utilisateur a bien été mis à jour."
    end
    list
  end

  def new
    redirect_to :action => 'signup'
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
        flash[:notice] = "Enregistrement réussi, n'oubliez pas de vérifier son profil<br />"
        @identifiant.create_person(client)
        flash[:notice] += (@identifiant.client ? 'Bénéficiaire' : 'Ingénieur ') +
          ' associé créé'
        
        # welcome mail
        options = { :identifiant => @identifiant, :controller => self,
          :password => params[:identifiant][:password]}
        Notifier::deliver_identifiant_nouveau(options, flash)

        redirect_back_or_default :action => "list"
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
  COLUMNS = [ 'Nom complet', 'Titre', 'Email', 'Téléphone', 
              'Identifiant', 'Mot de passe', 'Informations' ]

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
        flash.now[:warn] = 'Veuillez rentrer un texte sous format CSV'
      end
      COLUMNS.each { |key|
        unless row.include? key
          flash.now[:warn] = 'Le fichier CSV n\'est pas bien formé'
        end
      }
      if params[:identifiant].nil? or params[:identifiant][:client].nil? 
        flash.now[:warn] = 'Vous n\'avez pas spécifié de client'
      end
      if params[:identifiant][:role_ids].nil?
        flash.now[:warn] = 'Vous devez spécifier un rôle'
      end

      return unless flash.now[:warn] == ''
      flash[:notice] = ''
      roles = Role.find(params[:identifiant][:role_ids])

      FasterCSV.parse(params['textarea_csv'].to_s.gsub("\t", ";"), 
                      { :col_sep => ";", :headers => true }) do |row|
        identifiant = Identifiant.new do |i|
           logger.debug(row.inspect)
           i.nom = row['Nom Complet'].to_s
           i.titre = row['Titre'].to_s
           i.email = row['Email'].to_s
           i.telephone = row['Téléphone'].to_s
           i.login = row['Identifiant'].to_s
           i.password = row['Mot de passe'].to_s
           i.password_confirmation = row['Mot de passe'].to_s
           i.informations = row['Informations'].to_s
           i.client = params[:identifiant][:client]
        end
        identifiant.roles = roles
        if identifiant.save
          client = Client.find(params[:client][:id])
          flash[:notice] += "L'utilisateur #{row['Nom Complet']} a bien été créé.<br/>"
          identifiant.create_person(client)
          flash[:notice] += (@identifiant.client ? 'Bénéficiaire' : 'Ingénieur ') +
            ' associé créé'
          options = { :identifiant => identifiant, :controller => self,
            :password => row['Mot de passe'].to_s }
          Notifier::deliver_identifiant_nouveau(options, flash)
          flash[:notice] += '<br/>'
        else
          flash.now[:warn] += "L'utilisateur #{identifiant.nom} n'a " + 
            'pas été créé.<br/>'
        end

      end
      redirect_back_or_default :action => "list"
    when :get
    end
  end

  # Ajaxified list
  def list
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
         menu << (session[:user].authorized?('demandes/list') ? '<a class="no_hover">'+search_demande+'</a>' : nil ) 
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
    render_to_string :inline => <<-EOF
      <% infos = []  
         infos << link_to_modify_account(session[:user], _('Mon&nbsp;compte'))
         infos << link_to('Déconnexion',:controller => 'account', :action => 'logout')
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

  # Empeche les bénéficiaires de toucher à un autre compte qu'au leur
  def scope_beneficiaire
    if @beneficiaire
      conditions = [ 'identifiants.id = ?', @beneficiaire.identifiant_id ]
      scope = { :find => {:conditions => conditions } }
      Identifiant.with_scope(scope) { yield }
    else
      yield
    end
  end

end
