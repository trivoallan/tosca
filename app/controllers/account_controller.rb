#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

class AccountController < ApplicationController
  helper :knowledges

  # Pour l'import de plusieurs utilisateurs
  require 'fastercsv'
  PasswordGenerator

  # No clear text password in the log.
  # See http://api.rubyonrails.org/classes/ActionController/Base.html#M000441
  filter_parameter_logging :password

  helper :filters, :ingenieurs, :beneficiaires, :roles, :export

  around_filter :scope, :except => [:login, :logout]

  def authorize?(user)
    if params.has_key? :id
      id = params[:id].to_i
      # Only admins & manager can edit other accounts
      if user.role_id > 2 && id != user.id
        return false
      end
    end
    super(user)
  end

  def index
    # init
    options = { :per_page => 15, :order => 'users.role_id, users.login',
      :include => [:beneficiaire,:ingenieur,:role] }
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
        [:name, 'users.name', :like ],
        [:client_id, 'beneficiaires.client_id', :equal ],
        [:role_id, 'users.role_id', :equal ]
      ])
      flash[:conditions] = options[:conditions] = conditions
      @filters = accounts_filters
    end
    User.send(:with_scope, User.get_scope(session[:user].contrat_ids)) do
      @user_pages, @users = paginate :users, options
    end
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
      user_crypt = params.has_key?('user_crypt') ? params['user_crypt'] : 'false'
      if session[:user] = User.authenticate(params['user_login'],
                                            params['user_password'],
                                            user_crypt)
        set_sessions(session[:user])
        flash[:notice] = _("Welcome&nbsp;%s&nbsp;%s") %
          [ session[:user].title, session[:user].name.gsub(' ', '&nbsp;') ]
        session[:return_to] ||= request.env['HTTP_REFERER']
        redirect_back_or_default bienvenue_path
      else
        clear_sessions
        id = User.find_by_login(params['user_login'])
        flash.now[:warn] = _("Connexion failure")
        flash.now[:warn] << ", " << _("your account has been desactivated") if id and id.inactive?
      end
    end
  end

  # Let an Engineer become a client user
  def become
    begin
      if @ingenieur
        benef = Beneficiaire.find(params[:id])
        set_sessions(benef.user)
      else
        flash[:warn] = _('You are not allowed to change your identity')
      end
      redirect_to_home
    rescue ActiveRecord::RecordNotFound
      flash[:warn] = _('Person not found')
      redirect_to_home
    end
  end

  def edit
    @user = User.find(params[:id])
    @user_recipient, @user_engineer = @user.beneficiaire, @user.ingenieur
    _form
  end

  def ajax_place
    return render(:nothing => true) unless request.xhr? and params.has_key? :client
    if params[:client] == 'true'
      @user_recipient = Beneficiaire.new
    else
      @user_engineer = Ingenieur.new
    end
    @user = User.new
    _form
  end

  def ajax_contracts
    if !request.xhr? || !params.has_key?(:client_id) || !params.has_key?(:id)
      return render(:nothing => true)
    end

    client_id = params[:client_id].to_i
    user_id = params[:id].to_i
    options = Contrat::OPTIONS
    if client_id == 0
      @contrats = Contrat.find_select(options, false)
    else
      options = options.dup.update(:conditions =>
        ['contrats.client_id = ?', client_id ])
      @contrats = Contrat.find_select(options, false)
    end
    @user = (user_id == 0 ? User.new : User.find(user_id))
  end

  def show
    @user = User.find(params[:id])
    @user_recipient, @user_engineer = @user.beneficiaire, @user.ingenieur
    _form
  end

  def update
    @user = User.find(params[:id])
    @user_recipient, @user_engineer = @user.beneficiaire, @user.ingenieur

    # Security Wall
    if session[:user].role_id > 2 # Not a manager nor an admin
      params[:user].delete :role_id
      params[:user].delete :contrat_ids
    end

    res = @user.update_attributes(params[:user])
    if res and @user_recipient
      res &= @user_recipient.update_attributes(params[:beneficiaire])
    end
    if res and @user_engineer
      res &= @user_engineer.update_attributes(params[:ingenieur])
    end
    _form and return render(:action => 'edit')  unless res

    #update cached profile for logged user
    set_sessions @user if session[:user] == @user

    flash[:notice]  = _("Edition succeeded")
    redirect_to account_path(@user)
  end

  def new
    redirect_to signup_new_account_path
  end

  # Create an account
  # Depending on if is a client, create related beneficiaire or engineer
  # TODO : rework : it's too long !
  def signup
    case request.method
    when :post
      @user = User.new(params['user'])
      @user.generate_password # from PasswordGenerator, see lib/
      if @user.save
        connection = @user.connection
        begin
          connection.begin_db_transaction

          client_id = params[:user_recipient][:client_id].to_i
          client = (client_id != 0 ? Client.find(client_id) : nil)
          flash[:notice] = _("Account successfully created.")
          @user.create_person(client)
          benef, inge = @user.beneficiaire, @user.ingenieur
          benef.update_attributes(params[:beneficiaire]) if benef
          inge.update_attributes(params[:ingenieur]) if inge

          # welcome mail
          options = { :user => @user, :controller => self,
            :password => @user.pwd }
          Notifier::deliver_new_user(options, flash)
          connection.commit_db_transaction

          redirect_back_or_default account_path(@user)
        rescue Exception => e
          connection.rollback_db_transaction
          flash[:warn] = e.message
        end
      end
    when :get
      @user = User.new(:role_id => 4) # Default : customer
      @user_engineer = Ingenieur.new
    end
    _form
  end

  # Exit gracefully
  def logout
    clear_sessions
    redirect_to "/"
  end

  # Format du fichier CSV
  COLUMNS = [ _('Full name'), _('Title'), _('Email'), _('Phone'),
              _('Login'), _('Password'), _('Informations') ]


private
  # Partial variables used in forms
  def _form
    options = { :order => 'id', :conditions =>
      [ 'roles.id >= ? ', session[:user].role_id ] }
    @roles = Role.find_select(options, false)
    _form_recipient; _form_engineer
  end

  def _form_recipient
    return unless @user_recipient
    @clients = Client.find_select({}, false)
    @contrats = @user_recipient.client.contrats || @clients.first.contrats
    @clients.collect!{|c| [c.name, c.id] }
    @user.role_id = 4 if @user.new_record?
  end

  def _form_engineer
    return unless @user_engineer
    @competences = Competence.find_select({}, false)
    @contrats = Contrat.find_select(Contrat::OPTIONS, false)
    @clients = [Client.new(:id => 0, :name => '» ')].concat(Client.find_select)
    @user.role_id = 3 if @user.new_record?
  end

  # Variables utilisé par le panneau de gauche
  def _panel
    if session[:user].role_id <= 2
      @count = {}
      @clients = Client.find_select

      @count[:users] = User.count
      @count[:beneficiaires] = Beneficiaire.count
      @count[:ingenieurs] = Ingenieur.count
    end
  end

  # variable utilisateurs; nécessite session[:user]
  # penser à mettre à jour les pages statiques 404
  # et 500 en cas de modification
  # Le menu du layout est inclus pour des raisons de performances
  def set_sessions(user)
    return_to = session[:return_to]
    # clear_session erase session[:user]
    clear_sessions

    # restoring previously consulted page
    session[:return_to] = return_to

    # Set user properties
    session[:user] = user

    # Account links in header
    session[:account_links] = set_account_links
  end

  # Build account links
  def set_account_links
    logout = _("Logout")
    my_account = _("My account")
    render_to_string :inline => <<-EOF
      <% infos = [
           link_to("#{my_account}", edit_account_path(session[:user])),
           public_link_to("#{logout}", logout_accounts_path, :method => :post)
         ]
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


    # Bulk import users
  # TODO : this method is too fat, unused, untested and have a lots
  # of improvements possibility. It's deactivated for now, until we have sometime
  # to work this cleanly
=begin
  def multiple_signup
    _form
    @user = User.new
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
      if !params.has_key? :user or params[:user][:client].blank?
        flash.now[:warn] = _('You have to specify a customer')
      end
      if !params.has_key? :user or params[:user][:role_ids].blank?
        flash.now[:warn] = _('Vous must specify a role')
      end

      return unless flash.now[:warn] == ''
      flash[:notice] = ''

      FasterCSV.parse(params['textarea_csv'].to_s.gsub("\t", ";"),
                      { :col_sep => ";", :headers => true }) do |row|
        user = User.new do |i|
           logger.debug(row.inspect)
           i.name = row[_('Full name')].to_s
           i.title = row[_('Title')].to_s
           i.email = row[_('Email')].to_s
           i.phone = row[_('Phone')].to_s
           i.login = row[_('Login')].to_s
           i.password = row[_('Password')].to_s
           i.password_confirmation = row[_('Password')].to_s
           i.informations = row[_('Informations')].to_s
           i.client = true
        end
        if user.save
          client = Client.find(params[:client][:id])
          flash[:notice] += _("The user %s have been successfully created.<br />") % row[_('Full name')]
          user.create_person(client)
          options = { :user => user, :controller => self,
            :password => row[_('Password')].to_s }
          Notifier::deliver_new_user(options, flash)
          flash[:notice] += '<br />'
        else
          flash.now[:warn] += _('The user %s  has not been created.<br /> ') %
            user.name
        end

      end
      redirect_back_or_default accounts_path
    when :get
    end
  end
=end

end
