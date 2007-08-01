#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Notifier < ActionMailer::Base
  helper :mail

  FROM = 'lstm@noreply.08000linux.com'
  HTML_CONTENT = 'text/html'
  TEXT_CONTENT = 'text/plain'

  # To send a text and html mail it's simple
  # fill the recipients, from, subject, cc, bcc of your mail
  # then call the html_and_text_body method with a parameter
  # this parameter is the variables you want to use in the view of your mail

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
    demande = options[:demande]

    recipients  options[:identifiant].email
    from        FROM
    subject    "Accès au Support Logiciel Libre"

    html_and_text_body(options);

    if flash and flash[:notice]
      flash[:notice] << message_notice(@recipients, nil)
    end
  end

  # This function require 3 parameters : :demande, :controller, :nom
  def demande_nouveau(options, flash)
    demande =  options[:demande]

    recipients  compute_recipients(demande)
    cc          compute_copy(demande)
    from        FROM
    subject     "[OSSA:##{demande.id}] : #{demande.resume}"

    html_and_text_body(options);

    if flash and flash[:notice]
      flash[:notice] << message_notice(@recipients, @cc)
    end
  end

  # This function needs 4 options : :demande, :nom, :commentaire, :url_request
  def demande_nouveau_commentaire(options, flash)
    demande = options[:demande]

    recipients compute_recipients(demande)
    cc         compute_copy(demande) 
    from       FROM
    subject    "[OSSA:##{demande.id}] : #{demande.resume}"
    
    html_and_text_body(options)

    if flash and flash[:notice]
      flash[:notice] << message_notice(@recipients, @cc)
    end
  end

  def bienvenue_suggestion(text, to, from)
    case to
      when :team :
        recipients MAIL_TEAM
      when :tosca :
        recipients MAIL_TOSCA
      else
        recipients MAIL_MAINTENER
    end
    from    FROM
    subject "[Suggestion] => #{to}"

    options = Hash.new
    options[:suggestion] = text
    options[:author] = from

    html_and_text_body(options)
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

  MULTIPART_CONTENT = 'multipart/alternative'
  SUFFIX_VIEW = ".multi.rhtml"
  def html_and_text_body(body)
    method = caller[0].slice(/`.+'/).delete("`'") + SUFFIX_VIEW
    
    message_html = render_message(method, body)

    content_type MULTIPART_CONTENT
    part :content_type => TEXT_CONTENT,
      :body => html2text(message_html)

    part :content_type => HTML_CONTENT,
      :body => message_html
  end

end
