#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class AccountController < ApplicationController
  helper :knowledges

  cache_sweeper :user_sweeper, :only => [:signup, :update]

  PasswordGenerator

  # No clear text password in the log.
  # See http://api.rubyonrails.org/classes/ActionController/Base.html#M000441
  filter_parameter_logging :password

  helper :filters, :ingenieurs, :recipients, :roles, :export

  around_filter :scope, :except => [:login, :logout, :lemon]

  skip_before_filter :login_required, :only => [:login, :logout]


  # Only available with POST, see config/routes.rb
  def login
    case request.method
    when :post
      # For automatic login from an other web tool,
      # password is provided already encrypted
      user_crypt = params.has_key?('user_crypt') ? params['user_crypt'] : 'false'
      if session[:user] = User.authenticate(params['user_login'],
                                                    params['user_password'],
                                                    user_crypt)
        _login(session[:user])
        # When logged from an other tool, the referer is not a valid page
        session[:return_to] ||= request.env['HTTP_REFERER'] unless user_crypt
        redirect_back_or_default welcome_path
      else
        clear_sessions
        id = User.find_by_login(params['user_login'])
        flash.now[:warn] = _("Connexion failure")
        flash.now[:warn] << ", " << _("your account has been desactivated") if id and id.inactive?
      end
    else # Display form
    end
  end

  # Exit gracefully
  def logout
    theme, last_user = session[:theme], session[:last_user]
    clear_sessions
    # preserve theme, what ever happens
    session[:theme] = theme

    # in case of "su" style use, relog to previous one
    _login(last_user) if last_user
    redirect_to "/"
  end

  def new
    redirect_to signup_new_account_path
  end

  # It's a bi-directionnal method, which display and process the form
  def signup
    case request.method
    when :get # Display form
      @user = User.new(:role_id => 4, :client => true) # Default : customer
      @user_recipient = Recipient.new
    when :post # Process form
      @user = User.new(params['user'])
      @user.generate_password # from PasswordGenerator, see lib/
      connection = @user.connection
      begin
        connection.begin_db_transaction
        if @user.save
          associate_user!
          Notifier::deliver_user_signup({:user => @user}, flash)
          # The commit has to be after sending email, not before
          connection.commit_db_transaction
          flash[:notice] = _("Account successfully created.")
          redirect_to account_path(@user)
        else
          # Those variables are used by _form in order to display the correct form
          associate_user
          @user_recipient, @user_engineer = @user.recipient, @user.ingenieur
        end
      rescue Exception => e
        connection.rollback_db_transaction
        flash[:warn] = e.message
      end
    end
    _form
  end

  def show
    @user = User.find(params[:id])
    @user_recipient, @user_engineer = @user.recipient, @user.ingenieur
    _form
  end

  # TODO : Change ajax filter from client_id to contract_id, with
  # adequate changes in the Finder and in the Test Suite
  # TODO : this method is too long
  def index
    options = { :per_page => 15, :order => 'users.role_id, users.login',
      :include => [:recipient,:ingenieur,:role] }
    conditions = []
    @roles = Role.find_select

    if params.has_key? :filters
      session[:accounts_filters] = Filters::Accounts.new(params[:filters])
    end
    conditions = nil
    accounts_filters = session[:accounts_filters]
    if accounts_filters
      # Specification of a filter f :
      # [ namespace, field, database field, operation ]
      conditions = Filters.build_conditions(accounts_filters, [
        [:name, 'users.name', :like ],
        [:client_id, 'recipients.client_id', :equal ],
        [:role_id, 'users.role_id', :equal ]
      ])
      flash[:conditions] = options[:conditions] = conditions
      @filters = accounts_filters
    end

    # Experts does not need to be scoped on accounts, but they can filter
    # only on their contract.
    scope = {}
    if @recipient
      scope = User.get_scope(session[:user].contract_ids)
    end
    User.send(:with_scope, scope) do
      @user_pages, @users = paginate :users, options
    end
    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_for_summary = 'users_info'
    end
  end

  def edit
    @user = User.find(params[:id])
    @user_recipient, @user_engineer = @user.recipient, @user.ingenieur
    _form
  end

  def update
    @user = User.find(params[:id])
    @user_recipient, @user_engineer = @user.recipient, @user.ingenieur

    # Security Wall
    if session[:user].role_id > 2 # Not a manager nor an admin
      params[:user].delete :role_id
      params[:user].delete :contract_ids
    end

    res = @user.update_attributes(params[:user])
    if res and @user_recipient
      res &= @user_recipient.update_attributes(params[:user_recipient])
    end
    if res and @user_engineer
      res &= @user_engineer.update_attributes(params[:user_engineer])
    end
    if res # update of account fully ok
      set_sessions @user if session[:user] == @user
      flash[:notice]  = _("Edition succeeded")
      redirect_to account_path(@user)
    else
      # Don't write this :  _form and render :action => 'edit'
      # Else, tosca returns an error. It don't find the template
      _form
      render(:action => 'edit')
    end
  end

  # login with lemon-ldap technology.
  # Administrator ensures that only authenticated client
  #  can have access to this page, and provides some HTTP headers
  #  in order to log in / create an engineer account.
  def lemon
    [ [ 'HTTP_AUTH_CN', :name ],
      [ 'HTTP_AUTH_MAIL', :email ],
      [ 'HTTP_AUTH_MOBILE', :phone ],
      [ 'HTTP_AUTH_O', :description ], # Company
      # Unused : [ 'HTTP_AUTH_SN', :Cherif ],
      [ 'HTTP_AUTH_USER',  :login ] # TODO : check this field with Bayrem
    ]
    redirect_to welcome_path
=begin
    login = request.env['HTTP_AUTH_LOGIN']
    return redirect_to(welcome_path) unless login
    user = User.find(:first, :conditions => { :login => login })
    if user
      _login user
    end
    redirect_to(welcome_path)
=end
  end

  def forgotten_password
    case request.method
    when :get
      # Do nothing
    when :post
      user = params[:user]
      return unless user && user.has_key?(:email) && user.has_key?(:login)
      flash[:warn] = _('Unknown account')
      conditions = { :email => user[:email], :login => user[:login] }
      @user = User.find(:first, :conditions => conditions)
      return unless @user
      if @user.generate_password and @user.save
        flash[:warn] = nil
        flash[:notice] = _('Your new password has been generated.')
        Notifier::deliver_user_signup({:user => @user}, flash)
      end
    end
  end

  # Let an Engineer become a client user
  def become
    begin
      if @ingenieur
        current_user = session[:user]
        set_sessions(Recipient.find(params[:id]).user)
        session[:last_user] = current_user
      else
        flash[:warn] = _('You are not allowed to change your identity')
      end
      redirect_to_home
    rescue ActiveRecord::RecordNotFound
      flash[:warn] = _('Person not found')
      redirect_to_home
    end
  end

  # Used during creation to display engineer or recipient form
  def ajax_place
    return render(:nothing => true) unless request.xhr? and params.has_key? :client
    if params[:client] == 'true'
      @user_recipient = Recipient.new
    else
      @user_engineer = Ingenieur.new
    end
    @user = User.new
    _form
  end

  # Used to list contracts during creation/edition
  def ajax_contracts
    if !request.xhr? || !params.has_key?(:client_id)
      return render(:nothing => true)
    end

    client_id = params[:client_id].to_i
    user_id = (params.has_key?(:id) ? params[:id].to_i : nil)
    options = Contract::OPTIONS
    conditions = [ 'contracts.end_date >= ?', Time.now]
    unless client_id == 0
      conditions.first << ' AND contracts.client_id = ?'
      conditions.push(client_id)
    end
    options = options.dup.update(:conditions => conditions)
    @contracts = Contract.find_select(options)
    @user = (user_id.blank? ? User.new : User.find(user_id))
  end

  # Format du fichier CSV
  COLUMNS = [ _('Full name'), _('Title'), _('Email'), _('Phone'),
              _('Login'), _('Password'), _('Informations') ]


private
  def _login(user)
    set_sessions(user)
    flash[:notice] = (_("Welcome %s %s") %
                      [ user.title, user.name]).gsub(' ', '&nbsp;')

    user.active_contracts.each do |c|
      if (c.end_date - Time.now).between?(0.month, 1.month)
        message = '<br/><strong>'
        message << '</strong>'
        message << (_("Your contract '%s' is near its end date : %s") %
            [c.name, c.end_date_formatted])
        flash[:notice] << message
      end
    end
  end

  # Used to restrict operation
  #  One cannot edit account of everyone
  def authorize?(user)
    if params.has_key? :id
      id = params[:id].to_i
      # Only admins & manager can edit other accounts
      if user.role_id > 2 && id != user.id && action_name =~ /(edit|update)/
        return false
      end
    end
    super(user)
  end

  # Partial variables used in forms
  def _form
    conditions = (@user_engineer ?
                  [ 'roles.id BETWEEN ? AND 3', session[:user].role_id ] :
                  'roles.id BETWEEN 4 AND 5')
    options = { :order => 'id', :conditions => conditions }
    @roles = Role.find_select(options)
    _form_recipient; _form_engineer
  end

  def _form_recipient
    return unless @user_recipient
    @clients = Client.find_select({}, false)
    client_id = (@user_recipient.client ? @user_recipient.client_id : @clients.first.id)
    options = { :conditions => ['contracts.client_id = ?', client_id ]}

    @contracts = Contract.find_select(Contract::OPTIONS.merge(options))
    @clients.collect!{|c| [c.name, c.id] }
    @user.role_id = 4 if @user.new_record?
  end

  def _form_engineer
    return unless @user_engineer
    @competences = Competence.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
    # For usability matters, list of checkable own_contracts
    # won't contains any already available by the team.
    @contracts -= @user.team.contracts.find_select(Contract::OPTIONS) if @user.team
    @clients = [Client.new(:id => 0, :name => '» ')].concat(Client.find_select)
    @user.role_id = 3 if @user.new_record?
  end

  # Variables utilisé par le panneau de gauche
  def _panel
    if session[:user].role_id <= 2
      @count = {}
      @clients = Client.find_select

      @count[:users] = User.count
      @count[:recipients] = Recipient.count
      @count[:ingenieurs] = Ingenieur.count
    end
  end

  # variable utilisateurs; nécessite session[:user]
  # penser à mettre à jour les pages statiques 404
  # et 500 en cas de modification
  # Le menu du layout est inclus pour des raisons de performances
  def set_sessions(user)
    return_to, theme = session[:return_to], session[:theme]

    # clear_session erase session[:user]
    clear_sessions

    # restoring previously consulted page
    session[:return_to], session[:theme] = return_to, theme

    # Set user properties
    session[:user] = user
  end

  # Used during login and logout
  def clear_sessions
    @recipient = nil
    @ingenieur = nil
    reset_session
  end

  # Used during signup, It saves the associated recipient/expert
  # Put in a separate method in order to improve readiblity of the code
  def associate_user!
    associate_user
    benef, inge = @user.recipient, @user.ingenieur
    benef.update_attributes(params[:recipient]) if benef
    inge.update_attributes(params[:ingenieur]) if inge
  end

  # This one does not save anything, used when form was incorrectly setted
  def associate_user
    if params[:user][:client]=='false'
      @user.associate_engineer
    elsif params.has_key? :user_recipient
      @user.associate_recipient(params[:user_recipient][:client_id])
    end
  end


  # Bulk import users
  # TODO : this method is too fat, unused, untested and have a lots
  # of improvements possibility. It's deactivated for now, until
  # someone find some times in order have it work properly
  # require 'fastercsv'
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
