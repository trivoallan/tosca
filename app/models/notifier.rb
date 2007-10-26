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

  # This method requires 3 symbols in options :
  #   :identifiant, :controller, :password
  def new_user(options, flash)
    demande = options[:demande]

    recipients  options[:identifiant].email
    from        FROM
    subject    _("Access to Free Software Support")

    html_and_text_body(options);

    if flash and flash[:notice]
      flash[:notice] += message_notice(@recipients, nil)
    end
  end

  # This function require 3 parameters for options : :demande, :controller, :nom
  def request_new(options, flash)
    demande =  options[:demande]

    recipients  compute_recipients(demande)
    cc          compute_copy(demande)
    from        FROM
    subject     "[OSSA:##{demande.id}] : #{demande.resume}"
    headers     headers_mail_request(demande.first_comment)

    html_and_text_body(options);

    if flash and flash[:notice]
      flash[:notice] += message_notice(@recipients, @cc)
    end
  end

  # This function needs 4 options for options :demande, :nom, :commentaire, :url_request
  def request_new_comment(options, flash)
    request = options[:demande]
    # needed in order to have correct recipients
    # for instance, send mail to the correct engineer
    # when reaffecting a request
    request.reload

    recipients compute_recipients(request, options[:commentaire].prive)
    cc         compute_copy(request)
    from       FROM
    subject    "[OSSA:##{request.id}] : #{request.resume}"
    headers    headers_mail_request(options[:commentaire])

    html_and_text_body(options)

    if flash and flash[:notice]
      flash[:notice] += message_notice(@recipients, @cc)
    end
  end

  def welcome_idea(text, to, from)
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

  # http://i.loveruby.net/en/projects/tmail/doc/mail.html$
  # http://wiki.rubyonrails.org/rails/pages/HowToReceiveEmailsWithActionMailer
  # Kept In Order to have the code for generating recipients of a list
=begin
  def receive(email)
    from = email.from.first

    identifiants = Identifiant.find(:all, :conditions => [ "email = ?", from ])
    return Notifier::deliver_email_not_exist(from) if identifiants.empty?
    Notifier::deliver_email_multiple_account(from) if identifiants.size != 1

    possible_clients = Array.new
    adresses = email.cc.nil? ? email.to : email.to.concat(email.cc)
    for adresse in adresses
      clients = Client.find(:all, :conditions => [ "mailingliste = ?", adresse ])
      possible_clients.concat(clients)
    end

    return Notifier::deliver_email_mailinglist_not_exist(from, adresses) if possible_clients.empty?
    #We have a validate_uniqueness for Client.mailingliste so no need to test possible_clients.size > 1

    user = identifiants.first
    client = possible_clients.first

    email[HEADER_LIST_ID] = list_id(client)
    send_mail(client.mailingliste, client.ingenieurs.map { |e| e.identifiant.email }, email)
  end
=end


  private

  #Email when a received e-mail doe not exists in the database
  def email_not_exist(to)
    logger.info("E-mail #{to} does not exists in database")

    from       FROM
    recipients to
    bcc        MAIL_TOSCA
    subject    "#{Metadata::SITE_INTERNET} : " << _("Possible error in your e-mail")

    html_and_text_body
  end

  #E-mail when multiple accounts have the same e-mail
  def email_multiple_account(to)
    logger.info("E-mail #{to} corresponds to multiple users")

    from       FROM
    recipients to
    subject    "#{Metadata::SITE_INTERNET} : " << _("Multiple accounts with the same e-mail")

    html_and_text_body
  end

  #E-mail when mailinglist does not exists
  def email_mailinglist_not_exist(to, adresses)
    mailinglist = adresses.grep(/#{Metadata::SITE_INTERNET}$/)
    logger.info("This(These) e-mail(s) #{mailinglist} does not correspond to a valid mailing-list")

    from       FROM
    recipients to
    subject    "#{Metadata::SITE_INTERNET} : " << _("Mailing list does not exists")

    options = Hash.new
    options[:mailinglist] = mailinglist

    html_and_text_body(options)
  end

  HEADER_MESSAGE_ID = "Message-Id"
  HEADER_REFERENCES = "References"
  HEADER_IN_REPLY_TO = "In-Reply-To"
  HEADER_LIST_ID = "List-Id"

  #Usage : send_mail("toto@toto.com", ["tutu@toto.com", "tata@toto.com"], email)
  #The email param is a TMail::Mail
  def send_mail(from, to, mail)
    #See ActionMailer::Base::perform_delivery_smtp
    Net::SMTP.start(smtp_settings[:address], smtp_settings[:port], smtp_settings[:domain],
                    smtp_settings[:user_name], smtp_settings[:password], smtp_settings[:authentication]) do |smtp|
      smtp.sendmail(mail.encoded, from, to)
    end
  end

  def compute_copy(demande)
    res = demande.beneficiaire.client.mailingliste
    if demande.mail_cc and demande.mail_cc.size > 4
      res += ", " << demande.mail_cc
    end
    res
  end

  def compute_recipients(demande, private = false)
    result = ""
    # The client is not informed of private messages
    result += demande.beneficiaire.identifiant.email if not private
    # Request are not assigned, by default
    if demande.ingenieur
      result += ", " if not private
      result += demande.ingenieur.identifiant.email
    end
    result
  end

  def message_notice(recipients, cc)
    result = "<br />" << _("An e-mail informing") << " <b>#{recipients}</b> "
    result << "<br />" << _("with a copy to") << " <b>#{cc}</b> " if cc
    result << _("was sent.")
  end

  MULTIPART_CONTENT = 'multipart/alternative'
  SUFFIX_VIEW = ".multi.rhtml"
  def html_and_text_body(body = Hash.new)
    method = caller[0].slice(/`.+'/).delete("`'") + SUFFIX_VIEW

    message_html = render_message(method, body)

    content_type MULTIPART_CONTENT
    part :content_type => TEXT_CONTENT,
      :body => html2text(message_html)

    part :content_type => HTML_CONTENT,
      :body => message_html
  end

  #For mail headers : http://www.expita.com/header1.html
  def headers_mail_request(comment)
    headers = Hash.new
    headers[HEADER_MESSAGE_ID] = message_id(comment.mail_id)
    #Refers to the request
    headers[HEADER_REFERENCES] = headers[HEADER_IN_REPLY_TO] = message_id(comment.demande.first_comment.mail_id)
    return headers
  end

  # Used for outgoing mails, in order to get a Tree of messages
  # in mail softwares
  def message_id(id)
    "<#{id}@#{Metadata::NOM_COURT_APPLICATION}.#{Metadata::SITE_INTERNET}>"
  end

  def list_id(client)
    "#{client.nom} <#{client.mailingliste}>"
  end

end
