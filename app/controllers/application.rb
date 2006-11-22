
# Controller general de l'application
# Les filtres ajoutés à ce controller seront chargés pour tous les autres.
# De même, toutes les méthodes ajoutées ici seront disponibles.

# authentification
require_dependency "login_system"
# gestion des roles et des permissions
# en cas de soucis : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/versions/468
require_dependency "acl_system" 



class ApplicationController < ActionController::Base

  meantime_filter :scope_beneficiaire

  before_filter :set_charset
  before_filter :set_global_shortcuts
  before_filter :login_required, :except => [:refuse, :login]

  # systems d'authentification 
  include LoginSystem
  include ACLSystem
  model :identifiant

  # layout standard
  layout "standard-layout"

  # variables globales
  def set_global_shortcuts
    # TODO : encore nécessaire ? Non !!
    # groupe
    set_sessions unless @session[:filtres]
    @ingenieur = @session[:ingenieur]
    @beneficiaire = @session[:beneficiaire]
    @user_group = (@ingenieur ? 'ingénieur' : 'bénéficiaire')

  end
  
  protected
  
  # variable utilisateurs; nécessite @session[:user]
  def set_sessions
    return unless @session[:user]
    @session[:filtres] = Hash.new
    @session[:beneficiaire] = @session[:user].beneficiaire
    @session[:ingenieur] = @session[:user].ingenieur
    url_logo = '<%= image_tag url_for_file_column(Photo.find(6), "image", "thumb")%>'
    @session[:logo_08000] = render_to_string :inline => url_logo
  end

  # encodage
  def set_charset
    @headers["Content-Type"] = "text/html; charset=ISO-8859-1"
  end

  #scope
  def scope_beneficiaire
    yield
  end

private

  # notifie en cas d'erreur
  def log_error(exception)
    super
    Notifier::deliver_error_message(exception,
                                    clean_backtrace(exception),
                                    session.instance_variable_get("@data"),
                                    params,
                                    request.env)
  end

end



