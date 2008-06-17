#####################################################
# Copyright Linagora SA 2007 - Tous droits réservés.#
#####################################################

require 'xmpp4r'
module JabberNotifier

  @@jabbernotifier_logger = nil

  def send_jabber_notification()
    return unless defined? App::JabberAccount
    # Jabber::debug = true
    body = self.description
    subject = "[OSSA##{self.id}] : #{self.resume}"
    jid = Jabber::JID::new(App::JabberAccount)
    cl = Jabber::Client::new(jid)
    begin
      cl.connect
      cl.auth(App::JabberPassword)
    rescue
      @@jabbernotifier_logger.info "Jabber : Error login"
    end
    self.contract.engineer_users.each { |expert|
      message = Jabber::Message::new(expert.email, body).set_subject(subject)
      cl.send message
    }
    cl.close
  end

  def self.debug(string)
    return false if @@jabbernotifier_logger.nil?
    @@jabbernotifier_logger.info string
  end

  def self.included(mod)
    if mod.method_defined? "logger"
      @@jabbernotifier_logger = mod.logger
    end
  end

end

# overrides xmpp4r debuglog method to log message in tosca logger
def Jabber::debuglog(string)
  return if not Jabber::debug
  s = string.chomp.gsub("\n", "\n    ")
  t = Time::new.strftime('%H:%M:%S')
  # Log in stdout unless JabberNotifier could be log in tosca
  puts "#{t} #{s}" unless JabberNotifier::debug("#{t} #{s}")
end
