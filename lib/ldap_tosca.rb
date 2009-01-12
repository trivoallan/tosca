# Ldap authentication is active only if fill in the configuration file.
module LdapTosca

  CONFIGURATION_FILE = "#{RAILS_ROOT}/config/ldap.yml"

  def self.included(base)
    super(base)
    if File.exist?(CONFIGURATION_FILE)
      require 'ldap'
      base.extend(LdapToscaClassMethods)
    end
  end

  module LdapToscaClassMethods

    @@conf = nil
    def inherited(subclass)
      super(subclass)
      @@conf = YAML.load_file(CONFIGURATION_FILE)['ldap']
    end

    READ_ATTRIBUTES = ['uid', 'cn', 'mail', 'userpassword']
    #Get the user from the ldap
    #Return nil if there was an error
    def get_user(login)
      ldap_user = nil
      result = self.connect(self.configuration['binddn'], self.configuration['bindpw']) do |conn|
        ldap_user = conn.search2(self.configuration['basedn'],
          eval(self.configuration['scope']),
          self.configuration['filter'].gsub(/\?/, login),
          READ_ATTRIBUTES).first
      end
      ldap_user || result
    end

    #Authentificate the user
    def authentificate_user(login, password)
      result = false
      ldap_conn = self.connect(login, password) do |conn|
        result = true if conn.bound?
      end
      result || ldap_conn
    end

    # Key method, coming from User AR model
    def authenticate(login, pass)
      ldap_user = self.get_user(login)
      return nil unless ldap_user and self.authentificate_user(ldap_user['dn'].first, pass)

      user = nil
      User.with_exclusive_scope do
        user = User.first(:conditions => { :login => login })
      end
      unless user
        # Expert only for the moment
        user = User.create(:login => ldap_user['uid'].first,
          :name => ldap_user['cn'].first,
          :email => ldap_user['mail'].first,
          :password => ldap_user['userPassword'].first,
          :client_id => nil,
          :role_id => 3)
        # TODO send email, something
      end
      (user and user.inactive? ? nil : user)
    end

    protected

    # It's setted when it's extended, see inherited
    def configuration
      @@conf
    end

    #Connect to the LDAP and handle errors
    #Takes a bloc which yields the connection
    #Return nil if there was a problem
    def connect(binddn, bindpw)
      ldap_conn = LDAP::Conn.new(self.configuration['host'], self.configuration['port'])
      ldap_conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, self.configuration['protocol'])
      begin
        ldap_conn.bind(binddn, bindpw)
        yield(ldap_conn) if ldap_conn.bound?
        ldap_conn.unbind
      rescue LDAP::ResultError
        ldap_conn.unbind if ldap_conn.bound?
        ldap_conn = nil
      end
      ldap_conn
    end
  end
end
