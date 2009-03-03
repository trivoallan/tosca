#
# Copyright (c) 2006-2009 Linagora
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

  #Header for mails
  HEADER_MESSAGE_ID     = "Message-Id"
  HEADER_REFERENCES     = "References"
  HEADER_IN_REPLY_TO    = "In-Reply-To"
  HEADER_LIST_ID        = "List-Id"
  HEADER_XSOFTWARE      = "X-Tosca-Software"
  HEADER_XCONTRACT      = "X-Tosca-Contract"
  HEADER_XCLIENT        = "X-Tosca-Client"
  HEADER_XASSIGNEE      = "X-Tosca-Assignee"

  # To send a text and html mail it's simple
  # fill the recipients, from, subject, cc, bcc of your mail
  # then call the html_and_text_body method with a parameter
  # this parameter is the variables you want to use in the view of your mail

  # Notifie un état d'erreur
  def error_message(exception, trace, session, params, env)
    @recipients = App::DeveloppersEmail
    @cc = App::MaintenerEmail
    @from = App::NoReplyEmail
    @content_type = HTML_CONTENT
    @subject = "Time to fix this one : #{env['REQUEST_URI']}"
    user = "Nobody"
    if session and session.has_key?(:user) and session[:user].name
      user = session[:user].name
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

  # This method takes a User in parameter and send a welcome email,
  # with its password
  def user_signup(user)
    recipients  user.email
    from        App::NoReplyEmail
    reply_to    App::NoReplyEmail
    subject     "Accès au Support Logiciel Libre"

    html_and_text_body(:user => user)
  end

  # This function require 1 parameter : the issue
  def issue_new(issue)
    options = {}
    options[:issue] = issue
    options[:comment] = issue.first_comment
    options[:attachment] = issue.first_comment.attachment

    _common_issue_headers(issue, issue.first_comment, issue.submitter)
    html_and_text_body(options);
  end

  # This function require 1 parameter : the comment
  def issue_new_comment(comment)
    issue = comment.issue
    # needed in order to have correct recipients
    # for instance, send mail to the correct engineer
    # when reaffecting an issue
    issue.reload

    options = {}
    options[:comment] = comment
    options[:issue] = issue
    options[:attachment] = comment.attachment

    _common_issue_headers(issue, comment, comment.user)
    html_and_text_body(options)
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
    from        from.email
    reply_to    App::NoReplyEmail
    subject "[Suggestion] => #{to}"

    options = {}
    options[:suggestion] = text
    options[:author] = from

    html_and_text_body(options)
  end

  def reporting_digest(user, data, mode, now)
    from        App::TeamEmail
    reply_to    App::NoReplyEmail
    recipients  user.email

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

  def new_user_ldap(user)
    recipients  User.admins.collect(&:email_name).join(', ')
    from        App::NoReplyEmail
    reply_to    App::NoReplyEmail
    subject     "Nouvel utilisateur provenant du LDAP"

    html_and_text_body({ :user => user });
  end

  # http://wiki.rubyonrails.org/rails/pages/HowToReceiveEmailsWithActionMailer
  # Kept In Order to have the code for generating recipients of a list
  # To active incomming emails :
  # $ sudo apt-get install postfix
  # edit /etc/aliases
  # add this line and replace tosca: by the username of incoming emails
  # tosca: "|RAILS_ENV=mail /path/to/tosca/script/runner 'Notifier.receive(STDIN.read)'"
  # $ sudo newaliases
  # You're ready for it, congratulations !
  def receive(email)
    from = email.from.first

    in_reply_to = email[HEADER_IN_REPLY_TO]
    references =  email[HEADER_REFERENCES]

    in_reply_to_id = extract_issue_id(in_reply_to)

    #Is the id in in_reply_to is equal to one of references
    if not in_reply_to_id or not same_issue_id?(references, in_reply_to_id)
      #The email is probably not a response to a e-mail from Tosca
      return Notifier::deliver_email_not_good(from)
    end

    #One e-mail by user, or if multiple e-mail same person
    user = User.first(:conditions => [ "email = ?", from ])
    return Notifier::deliver_email_not_exist(from) unless user

    issue = Issue.find(in_reply_to_id)
    return Notifier::deliver_email_not_good(from) unless issue

    unless issue.contract.users.include? user
      #The user has no rights on this contract
      return Notifier::deliver_email_no_rights_contract(from)
    end

    #The text of the comment
    text = nil
    attachment = nil
    if email.parts.size > 0
      email.parts.each do |part|
        if email.attachment?(part)
          #This part is an attachment
          #TODO
        else
          #This part is the mail
          text = get_text_from_email(part)
        end
      end
    else
      text = get_text_from_email(email)
    end

    comment = Comment.new do |c|
      c.issue = issue
      c.user = user
      c.attachment = attachment
      c.private = false
      c.text = text
    end
    logger.info("Text #{text.inspect}")
    comment.save

  end

  private

  def _common_issue_headers(issue, comment, user)
    recipients  issue.compute_recipients
    cc          issue.compute_copy
    from        user.email_name
    reply_to    App::NoReplyEmail
    subject     "[#{issue.id}] #{issue.resume}"
    headers     _headers_mail_issue(issue, comment)
  end

  #For mail headers : http://www.expita.com/header1.html
  def _headers_mail_issue(issue, comment)
    headers = {}
    headers[HEADER_MESSAGE_ID] = message_id(comment.mail_id)
    #Refers to the issue
    headers[HEADER_REFERENCES] = headers[HEADER_IN_REPLY_TO] = message_id((issue.first_comment || comment).mail_id)
    headers[HEADER_XSOFTWARE]  = issue.software.name.asciify if issue.software
    headers[HEADER_XCONTRACT]  = issue.contract.to_s.asciify!
    headers[HEADER_XCLIENT]    = issue.client.to_s.asciify
    headers[HEADER_XASSIGNEE]  = issue.engineer.name.asciify if issue.engineer
    return headers
  end

  def get_text_from_email(part)
    content_type = part.sub_type
    text = nil
    if content_type and content_type.include?("plain")
      #This is the text part of the e-mail
      #We remove the first lign before replied mail
      text = part.body.gsub(/(\n[^>]*\n)(>)/, "\n" + '\2')
      logger.info("Text 1 #{text}")
      #We remove the lines which come from the replied email
      text.gsub!(/^>.*$/, '')
      logger.info("Text 2 #{text}")
      #We remove the signature
      text = text.split(/^-- $/).first
      logger.info("Text 3 #{text}")
      #More lines but much faster
      text.strip!
      #We have a pseudo HTML comment
      text.gsub!(/\n/, "<br/>")
    elsif content_type and content_type.include?("html")
      #This is the html part of the e-mail
      #We remove the first lign before replied mail
      text = part.body.gsub(/(<br\/?>.*<br\/?>)(<\/?blockquote.*>)/i, '\2')
      #We remove alle the text between blockquotes tags
      text = text.split(/<\/?blockquote[^>]*>/i)
      text = text.join
    end
    text
  end

  #Email when a received e-mail does not exists in the database
  def email_not_exist(to)
    logger.info("E-mail #{to} does not exists in database")

    from       App::FromEmail
    recipients to
    bcc        App::TeamEmail
    subject    "#{App::InternetAddress} : " << _("Possible error in your e-mail")

    html_and_text_body
  end

  #Email when a received e-mail is not well formed
  def email_not_good(to)
    logger.info("Bad e-mail from #{to}")

    from       App::FromEmail
    recipients to
    bcc        App::TeamEmail
    subject    "#{App::InternetAddress} : " << _("Possible error in your e-mail")

    html_and_text_body
  end

  #Email when a user has no rights on a contract
  #TODO
  def email_no_rights_contract(to)
    logger.info("Bad e-mail from #{to}")

    from       App::FromEmail
    recipients to
    bcc        App::TeamEmail
    subject    "#{App::InternetAddress} : " << _("Possible error in your e-mail")

    html_and_text_body
  end
  #Usage : send_mail("toto@toto.com", ["tutu@toto.com", "tata@toto.com"], email)
  #The email param is a TMail::Mail
  def send_mail(from, to, mail)
    #See ActionMailer::Base::perform_delivery_smtp
    Net::SMTP.start(smtp_settings[:address], smtp_settings[:port], smtp_settings[:domain],
                    smtp_settings[:user_name], smtp_settings[:password], smtp_settings[:authentication]) do |smtp|
      smtp.sendmail(mail.encoded, from, to)
    end
  end

  MULTIPART_CONTENT = 'multipart/alternative'
  SUFFIX_VIEW = ".multi.html.erb"
  def html_and_text_body(body = {})
    method = caller[0].slice(/`.+'/).delete("`'") + SUFFIX_VIEW

    message_html = render_message(method, body)

    content_type MULTIPART_CONTENT
    part :content_type => TEXT_CONTENT,
      :body => html2text(message_html)

    part :content_type => HTML_CONTENT,
      :body => message_html
  end

  # Used for outgoing mails, in order to get a Tree of messages
  # in mail software
  def message_id(id)
    "<#{id}@#{Tosca::App::Name}.#{App::InternetAddress}>"
  end

  #Extracts the issue number from a header
  def extract_issue_id(string)
    string = string.to_s
    string.strip!
    string.gsub!(/[<\>]/, '')
    result = nil
    result = string[/^\d+/] if string =~ /^\d+_\d+@#{Tosca::App::Name}.#{App::InternetAddress}$/
    return result
  end

  #Is the issue(s) id from a header is the same has the one in parameter
  def same_issue_id?(header, issue_id)
    header.to_s.split(" ").each do |e|
      id = extract_issue_id(e)
      return true if issue_id == id
    end
    false
  end

  #Compute the receiver of an email for the flash
  def message_notice(recipients, cc)
    result = "<br />" << _("An e-mail was sent to ") << " <b>#{recipients}</b> "
    result << "<br />" << _("with a copy to") << " <b>#{cc}</b>" if cc && !cc.blank?
    result << '.'
  end

end
