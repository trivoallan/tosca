#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Notifier < ActionMailer::Base
  helper :mail

  FROM = 'lstm@noreply.08000linux.com'
  HTML_CONTENT = 'text/html; charset=utf-8'
  TEXT_CONTENT = 'text/plain; charset=utf-8'

  # Notifie un état d'erreur
  def error_message(exception, trace, session, params, env)
    #@recipients = "mloiseleur@linagora.com"
    #@recipients = "rschermesser@linagora.com"
    @cc = 'lstm-devel@08000linux.com'
    @from = FROM
    @content_type = HTML_CONTENT
    @subject = "Time to fix this one : #{env['REQUEST_URI']}"
    user = "Nobody"
    if session
      user = session[:user].nom if session[:user] and session[:user].nom
    end
    @body = {
      :user => user,
      :exception => exception,
      :trace => trace,
      :params => params,
      :session => session,
      :env => env
    }
  end

#  part :content_type => "text/plain", :body => render_message('mailto', body)

#  attachment "application/txt" do |a|
#   ##erreur## a.disposition = "attachment"
#   a.filename= "piece_jointe_renommee.txt"
#   a.body = File.read(RAILS_ROOT + "/public/documents/piece_jointe.txt")
# end

  # This function require 3 parameters : :identifiant, :controller, :password
  def identifiant_nouveau(options, flash)
    # Email body substitutions go here
    @body = options
    # Email header info MUST be added here
    demande =  @body[:demande]
    @recipients = @body[:identifiant].email
    @from = FROM
    @content_type = HTML_CONTENT
    @subject = "Accès au Support Logiciel Libre"
    if flash and flash[:notice]
      flash[:notice] << message_notice(@recipients, nil)
    end
  end

  # This function require 3 parameters : :demande, :controller, :nom
  def demande_nouveau(options, flash)
    # Email body substitutions go here
    @body = options
    # Email header info MUST be added here
    demande =  @body[:demande]
    @recipients = compute_recipients(demande)
    @cc = compute_copy(demande)
    @from = FROM
    @content_type = HTML_CONTENT
    @subject = "[OSSA:##{demande.id}] : #{demande.resume}"
    if flash and flash[:notice]
      flash[:notice] << message_notice(@recipients, @cc)
    end
  end

  # This function require 2 parameters : :demande, :controller
  def demande_assigner(options, flash)
    # Email body substitutions go here
    @body = options
    # Email header info MUST be added here
    demande =  @body[:demande]
    @recipients = compute_recipients(demande)
    @cc = compute_copy(demande)
    @from = FROM
    @content_type = HTML_CONTENT
    @subject = "[OSSA:##{demande.id}] : #{demande.resume}"
    if flash and flash[:notice]
      flash[:notice] << message_notice(@recipients, @cc) 
    end
  end

  # This function require 5 parameters : :demande, :nom,
  # :controller, :commentaire, :request
  def demande_nouveau_commentaire(options, flash)
    # Email body substitutions go here
    @body = options
    # Email header info MUST be added here
    demande =  @body[:demande]
    @recipients = compute_recipients(demande)
    @cc = compute_copy(demande) 
    @from = FROM
    @content_type = HTML_CONTENT
    @subject = "[OSSA:##{demande.id}] : #{demande.resume}"
    if flash and flash[:notice]
      flash[:notice] << message_notice(@recipients, @cc)
    end
  end

  def bienvenue_suggestion(text, to, from)
    case to
    when :team : @recipients = MAIL_TEAM
    when :tosca : @recipients = MAIL_TOSCA
    else @recipients = MAIL_MAINTENER
    end
    @from = FROM
    @content_type= HTML_CONTENT
    @subject = "[Suggestion] => #{to}"
    # Email body substitutions go here
    @body[:suggestion] = text
    @body[:author] = from
  end

  private
  def compute_copy(demande)
    res = demande.beneficiaire.client.mailingliste
    if demande.mail_cc and demande.mail_cc.size > 4
      res << ", " << demande.mail_cc
    end
    res
  end

  def compute_recipients (demande)
    result = demande.beneficiaire.identifiant.email
    # l'ingénieur est non assigné initialement
    result += ", " + demande.ingenieur.identifiant.email if demande.ingenieur
    result
  end

  def message_notice (recipients, cc)
    result = "<br />Un email en informant <b>#{recipients}</b>, "
    result << "<br />avec en copie <b>#{cc}</b> " if cc
    result << "a été envoyé."
  end
end
