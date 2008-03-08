class LoadSystems < ActiveRecord::Migration
  class Socle < ActiveRecord::Base; end

  def self.up
    # Do not erase existing system
    return unless Socle.count == 0

    # sample known systems
    [ 'Ubuntu Dapper (6.04)', 'Ubuntu Dapper LTS (6.06)', 'Ubuntu Edgy (6.10)',
      'Ubuntu Feisty (7.04)', 'Ubuntu Gutsy (7.10)',
      'Mandriva Corporate 3', 'Mandriva Corporate 4',
      'Debian Potato (2.0)', 'Debian Sarge (3.0)', 'Debian Etch (4.0)',
      'RHES 3', 'RHEL 4', 'RHES 4',
      'Fedora Core 6', 'Fedora Core 7', 'Fedora 8',
      'Linux', 'Solaris 10', 'AIX',
      'Windows 2k', 'Windows XP', 'Windows Vista' ].each {|s|
      Socle.create(:nom => s)
    }
  end

  def self.down
    Socle.find(:all).each{ |s| s.destroy }
  end
end
