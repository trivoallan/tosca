#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AccountController < ApplicationController
  model   :identifiant
  layout  'standard-layout'

  helper :ingenieurs, :beneficiaires

  #before_filter :login_required, :except => [:login]

  def login
    case @request.method
      when :post
        if @session[:user] = Identifiant.authenticate(@params['user_login'], 
                                                       @params['user_password'], 
                                                       @params['user_crypt'])
          # set_sessions
          flash[:notice]  = "Connexion réussie"
          redirect_back_or_default :action => "list", :controller => 'bienvenue'
        else
          @login = @params['user_login']
          flash[:warn]  = "Echec lors de la connexion"
      end
    end
  end

  def _form
    @roles = Role.find_all
    @clients = Client.find_all
  end


  def devenir
    return unless @ingenieur
    benef = Beneficiaire.find(params[:account][:beneficiaire_id])
    @session[:user] = benef.identifiant
    set_sessions
    redirect_back_or_default :action => "list", :controller => 'bienvenue'
  end

  def modify
    _form
    case @request.method
    when :post
      @identifiant = Identifiant.find(params[:id])
      newIdentifiant = params[:identifiant]
      #on ne met pas à jour le mot de passe
      if newIdentifiant[:password] == ''
        newIdentifiant[:password] = @identifiant.password
        newIdentifiant[:password_confirmation] = @identifiant.password
      else
        @identifiant.change_password(newIdentifiant[:password])
        newIdentifiant[:password] = @identifiant.password
      end

      # pour update des roles accordéss
     
      @identifiant.roles = Role.find(@params[:role_ids])  if @params[:role_ids]


      if @identifiant.update_attributes(newIdentifiant)     
        flash[:notice]  = "Modification réussie, Vous devez vous reconnecter si vous avez modifier votre compte !"
        redirect_back_or_default :action => "list", :controller => 'bienvenue'
      end
    when :get
      @identifiant = Identifiant.find(params[:id])
      @identifiant.password_confirmation = @identifiant.password
    end      
  end  

  #utilisé dans account/list
  def update
    @user = Identifiant.find(params[:id])
    # j'ai pas fait de vérification, ça plante
    # pour update des roles accordéss
    if @params[:role_ids]
      @user.roles = Role.find(@params[:role_ids]) 
    else
      @user.roles = []
      # @user.errors.add_on_empty('roles') 
    end
    flash[:notice] = "L'utilisateur a bien été mis à jour."
    redirect_to :action => 'list'
  end
  
  def signup
    _form
    case @request.method
    when :post
      @identifiant = Identifiant.new(@params['identifiant'])
      if @params[:role_ids]
        @identifiant.roles = Role.find(@params[:role_ids]) 
      else
        @identifiant.roles = []
        @identifiant.errors.add_on_empty('roles') 
        render :action => 'signup'
        return 
      end

      if @identifiant.save
        client = Client.find(@params[:client][:id])
        flash[:notice] = "Enregistrement réussi, n'oubliez pas de vérifier son profil<br />"
        if @identifiant.client 
          beneficiaire = Beneficiaire.new(:identifiant => @identifiant,
                                         :client => client)
          flash[:notice] += "Beneficiaire associé créé" if beneficiaire.save
        else
          ingenieur = Ingenieur.new(:identifiant => @identifiant)
          flash[:notice] += "Ingénieur associé créé" if ingenieur.save
        end
        Notifier::deliver_identifiant_nouveau({:identifiant => @identifiant, 
                                                :controller => self,
                                                :password => @params[:identifiant][:password_confirmation]}, flash)         

        redirect_back_or_default :action => "list"  
      end
    when :get
      @identifiant = Identifiant.new
    end      
  end  
   
  def logout
    @session[:user] = nil
    @session[:beneficiaire] = nil
    @session[:ingenieur] = nil
    @session[:logo_08000] = nil
    @session[:filtres] = nil
    @beneficiaire = nil
    @ingenieur = nil
    redirect_to "/"
  end
    
  def welcome
  end
  
  ### ajouts pour test ###
  
  def list
    @clients = Client.find_all
    @user_pages, @users = paginate :identifiants, :per_page => 25
  end
  
  def destroy
    Identifiant.find(params[:id]).destroy
    redirect_back_or_default :action => "list", :controller => 'bienvenue'
  end

  private
  def scope_beneficiaire
    if @beneficiaire
      conditions = [ "identifiants.id = ?", @beneficiaire.identifiant_id ]
      Identifiant.with_scope({ :find => { 
                               :conditions => conditions
                               }
                             }) { yield }
    else
      yield
    end
  end

  

end
