class LoadSkills < ActiveRecord::Migration
  class Competence < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Knowledges
    return unless Competence.count == 0

    # All knowledges, severely reduced to an human size
    [ 'Admin / Réseau', 'Admin / Système', 'Annuaires', 'C / C++',
      'C# / Mono', 'Gestion', 'Java / J2ee', 'OpenOffice', 'Perl',
      'Php', 'Python', 'Ruby', 'SGBD / SQL', 'Web' ].each { |c|
      Competence.create(:nom => c)
    }
  end

  def self.down
    Competence.find(:all).each{ |c| c.destroy }
  end
end
