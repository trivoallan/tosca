module LdapTosca

  def self.included(base)
    super(base)
    base.extend(LdapToscaClassMethods)
    require 'ldap' if base.use_ldap?
  end

  module LdapToscaClassMethods
    CONFIGURATION_FILE = "#{RAILS_ROOT}/config/ldap.yml"
    def use_ldap?
      File.exist?(CONFIGURATION_FILE)
    end

    READ_ATTRIBUTES = ['uid', 'cn', 'mail', 'userpassword']
    #Get the user from the ldap
    #Return nil if there was an error
    def get_user(login)
      ldap_user = nil
      result = self.connect(self.configuration['binddn'], self.configuration['bindpw']) do |conn|
        ldap_user = conn.search2(self.configuration['basedn'],
          LDAP::LDAP_SCOPE_ONELEVEL,
          self.configuration['ldap_filter'].gsub(/\?/, login),
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

    private

    #Load the configuration one time
    @@conf = nil
    def configuration
      @@conf ||= YAML.load_file(CONFIGURATION_FILE)['ldap']
    end

    #Connect to the LDAP and handle errors
    #Takes a bloc which yields the connection
    #Return nil if there was a problem
    def connect(binddn, bindpw)
      ldap_conn = LDAP::Conn.new(self.configuration['host'], self.configuration['port'])
      ldap_conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, self.configuration['protocol'])
      begin
        ldap_conn.bind(binddn, bindpw)
        yield(ldap_con) unless ldap_conn.bound?
        ldap_conn.unbind
      rescue LDAP::ResultError
        ldap_conn.unbind if ldap_conn.bound?
        ldap_conn = nil
      end
      ldap_conn
    end
  end
end