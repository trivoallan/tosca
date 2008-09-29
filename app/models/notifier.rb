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
class Notifier < ActionMailer::Base
  helper :mail

  HTML_CONTENT = 'text/html'
  TEXT_CONTENT = 'text/plain'

  # To send a text and html mail it's simple
  # fill the recipients, from, subject, cc, bcc of your mail
  # then call the html_and_text_body method with a parameter
  # this parameter is the variables you want to use in the view of your mail

  # Notifie un état d'erreur
  def error_message(exception, trace, session, params, env)
    @recipients = App::DeveloppersEmail
    @cc = App::MaintenerEmail
    @from = App::FromEmail
    @content_type = HTML_CONTENT
    @subject = "Time to fix this one : #{env['REQUEST_URI']}"
    user = "Nobody"
    if session
      user = session[:user].name if session[:user] and session[:user].name
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

  # This method requires 3 symbols in options :
  #   :user, :controller, :password
  def user_signup(options, flash = nil)
    recipients  options[:user].email
    from        App::FromEmail
    subject     "Accès au Support Logiciel Libre"

    html_and_text_body(options);

    if flash and flash[:notice]
      flash[:notice] += message_notice(@recipients, nil)
    end
  end

  # This function require 4 parameters for options :
  #   :issue, :url_issue
  #   :name => user.name, :url_attachment
  def issue_new(options, flash = nil)
    issue =  options[:issue]

    recipients  compute_recipients(issue)
    cc          compute_copy(issue)
    from        App::FromEmail
    subject     "[#{App::ServiceName}##{issue.id}] : #{issue.resume}"
    headers     headers_mail_issue(issue.first_comment)

    html_and_text_body(options);

    if flash and flash[:notice]
      flash[:notice] += message_notice(@recipients, @cc)
    end
  end

  # This function needs too much options :
  #  { :issue, :name, :url_issue, :url_attachment, :comment }
  # And an optional
  #  :modifications => {:statut_id, :ingenieur_id, :severite_id }
  def issue_new_comment(options, flash = nil)
    issue = options[:issue]
    # needed in order to have correct recipients
    # for instance, send mail to the correct engineer
    # when reaffecting an issue
    issue.reload
    comment = options[:comment]

    recipients compute_recipients(issue, comment.private)
    cc         compute_copy(issue, comment.private)
    from       App::FromEmail
    subject    "[#{App::ServiceName}:##{issue.id}] : #{issue.resume}"
    headers    headers_mail_issue(comment)

    html_and_text_body(options)

    if flash and flash[:notice]
      flash[:notice] += message_notice(@recipients, @cc)
    end
  end

  def welcome_idea(text, to, from)
    case to
      when :team
        recipients App::TeamEmail
      when :tosca
        recipients App::DeveloppersEmail
      else
        recipients App::MaintenerEmail
    end
    from    App::FromEmail
    subject "[Suggestion] => #{to}"

    options = Hash.new
    options[:suggestion] = text
    options[:author] = from

    html_and_text_body(options)
  end

  def reporting_digest(user, data, mode, now)
    from       App::FromEmail
   recipients user.email

    case mode.to_sym
    when :day
      time = now.strftime("%A %d %B %Y")
      subject _("Daily digest for ") << time
    when :week
      time = _ordinalize(now.strftime("%U").to_i) << _(" week of ") << now.year.to_s
      subject _("Weekly digest for ") << time
    when :month
      time = now.strftime("%B of %Y")
      subject _("Monthly digest for ") << time
    else
      time = now.year.to_s
      subject _("Yearly digest for ") << time
    end

    html_and_text_body({ :result => data.other, :important => data.important, :time => time })
  end

  # http://i.loveruby.net/en/projects/tmail/doc/mail.html$
  # http://wiki.rubyonrails.org/rails/pages/HowToReceiveEmailsWithActionMailer
  # Kept In Order to have the code for generating recipients of a list
=begin
  def receive(email)
    from = email.from.first

    users = User.find(:all, :conditions => [ "email = ?", from ])
    return Notifier::deliver_email_not_exist(from) if users.empty?
    Notifier::deliver_email_multiple_account(from) if users.size != 1

    possible_clients = Array.new
    adresses = email.cc.nil? ? email.to : email.to.concat(email.cc)
    for adresse in adresses
      clients = Client.find(:all, :conditions => [ "mailingliste = ?", adresse ])
      possible_clients.concat(clients)
    end

    return Notifier::deliver_email_mailinglist_not_exist(from, adresses) if possible_clients.empty?
    #We have a validate_uniqueness for Client.mailingliste so no need to test possible_clients.size > 1

    user = users.first
    client = possible_clients.first

    email[HEADER_LIST_ID] = list_id(contract)
    send_mail(client.contract.mailingliste, contract.ingenieurs.map { |e| e.user.email }, email)
  end
=end

  private

  #Email when a received e-mail doe not exists in the database
  def email_not_exist(to)
    logger.info("E-mail #{to} does not exists in database")

    from       App::FromEmail
    recipients to
    bcc        App::TeamEmail
    subject    "#{App::InternetAddress} : " << _("Possible error in your e-mail")

    html_and_text_body
  end

  #E-mail when multiple accounts have the same e-mail
  def email_multiple_account(to)
    logger.info("E-mail #{to} corresponds to multiple users")

    from       App::FromEmail
    recipients to
    subject    "#{App::InternetAddress} : " << _("Multiple accounts with the same e-mail")

    html_and_text_body
  end

  #E-mail when mailinglist does not exists
  def email_mailinglist_not_exist(to, adresses)
    mailinglist = adresses.grep(/#{App::InternetAddress}$/)
    logger.info("This(These) e-mail(s) #{mailinglist} does not correspond to a valid mailing-list")

    from       App::FromEmail
    recipients to
    subject    "#{App::InternetAddress} : " << _("Mailing list does not exists")

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

  # private indicates if it's reserved for internal use or not
  def compute_copy(issue, private = false)
    if private
      issue.contract.internal_ml
    else
      res = []
      contract = issue.contract
      [ contract.internal_ml, contract.customer_ml, issue.mail_cc ].each { |m|
        res << m unless m.blank?
      }
      res.join(',')
    end
  end

  def compute_recipients(issue, private = false)
    res = []
    # The client is not informed of private messages
    res << issue.recipient.user.email unless private
    # Issue are not assigned, by default
    res << issue.ingenieur.user.email if issue.ingenieur
    res.join(',')
  end

  def message_notice(recipients, cc)
    result = "<br />" << _("An e-mail was sent to ") << " <b>#{recipients}</b> "
    result << "<br />" << _("with a copy to") << " <b>#{cc}</b>" if cc && !cc.blank?
    result << '.'
  end

  MULTIPART_CONTENT = 'multipart/alternative'
  SUFFIX_VIEW = ".multi.html.erb"
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
  def headers_mail_issue(comment)
    headers = Hash.new
    headers[HEADER_MESSAGE_ID] = message_id(comment.mail_id)
    #Refers to the issue
    headers[HEADER_REFERENCES] = headers[HEADER_IN_REPLY_TO] = message_id(comment.issue.first_comment.mail_id)
    return headers
  end

  # Used for outgoing mails, in order to get a Tree of messages
  # in mail software
  def message_id(id)
    "<#{id}@#{App::Name}.#{App::InternetAddress}>"
  end

=begin
  # There is NO outgoing mails, sadly. #
  ######################################

  def list_id(contract)
    "#{contract.name} <#{contract.internal_ml}>"
  end
=end
end
