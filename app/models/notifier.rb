#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Notifier < ActionMailer::Base
  helper :mail

# Notifie un état d'erreur
def error_message (exception, trace, session, params, env, envoye_le = Time.now)
  recipients = "mloiseleur@linagora.com"
  from = "lstm@noreply.08000linux.com"
  subject = "Message d'erreur : #{env['REQUEST_URI']}"
  envoye_le = envoye_le
  body = {
    :exception => exception,
    :trace => trace,
    :params => params,
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
  @content_type = "text/plain; charset=utf-8"
  @from = "noreply@08000linux.com"
  @subject = "Accès au Support Logiciel Libre"
  flash[:notice] << message_notice(@recipients, nil) if flash and flash[:notice]
end

# This function require 3 parameters : :demande, :controller, :nom
def demande_nouveau(options, flash)
  # Email body substitutions go here
  @body = options
  # Email header info MUST be added here
  demande =  @body[:demande]
  @recipients = compute_recipients(demande)
  @content_type = "text/plain; charset=utf-8"
  @cc = demande.beneficiaire.client.mailingliste
  @from = "noreply@08000linux.com"
  @subject = "[SLL:#{demande.id}] : #{demande.resume}"
  flash[:notice] << message_notice(@recipients, @cc) if flash and flash[:notice]
end


# This function require 2 parameters : :demande, :controller
def demande_assigner (options, flash)
  # Email body substitutions go here
  @body = options
  # Email header info MUST be added here
  demande =  @body[:demande]
  @recipients = compute_recipients(demande)
  @content_type = "text/plain; charset=utf-8"
@headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
  @cc = demande.beneficiaire.client.mailingliste
  @from = "noreply@08000linux.com"
  @subject = "[SLL:#{demande.id}] : #{demande.resume}"
  flash[:notice] << message_notice(@recipients, @cc) if flash and flash[:notice]
end

# This function require 4 parameters : :demande, :nom, :controller
def demande_change_statut (options, flash)
  # Email body substitutions go here
  @body = options
  # Email header info MUST be added here
  demande =  @body[:demande]
  @recipients = compute_recipients(demande)
  @content_type = "text/plain; charset=utf-8"
  @cc = demande.beneficiaire.client.mailingliste
  @from = "noreply@08000linux.com"
  @subject = "[SLL:#"+ demande.id.to_s + "] : " + demande.resume
  flash[:notice] << message_notice(@recipients, @cc) if flash and flash[:notice]
end

# This function require 5 parameters : :demande, :nom,
# :controller, :commentaire, :request
def demande_nouveau_commentaire(options, flash)
  # Email body substitutions go here
  @body = options
  # Email header info MUST be added here
  demande =  @body[:demande]
  @recipients = compute_recipients(demande)
  @content_type = "text/plain; charset=utf-8"
  @cc = demande.beneficiaire.client.mailingliste
  @from = "noreply@08000linux.com"
  @subject = "[SLL:#{demande.id}] : #{demande.resume}"
  flash[:notice] << message_notice(@recipients, @cc) if flash and flash[:notice]
end


private
  def compute_recipients (demande)
    result = demande.beneficiaire.identifiant.email
    result += ", " + demande.ingenieur.identifiant.email if demande.ingenieur # non assigné initialement
    result
  end

  def message_notice (recipients, cc)
    result = "<br />Un email en informant <b>#{recipients}</b>, "
    result << "<br />avec en copie <b>#{cc}</b> " if cc
    result << "a été envoyé."
  end

end



