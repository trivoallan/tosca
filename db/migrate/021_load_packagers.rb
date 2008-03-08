class LoadPackagers < ActiveRecord::Migration
  class Mainteneur < ActiveRecord::Base; end

  def self.up
    # Do not erase existing packagers
    return unless Mainteneur.count == 0

    # Sample ones
    [ '(none)', 'Anthony Mercatante', 'Emmanuel Seyman', 'Michel Loiseleur',
      'Dag Wieers', 'Alexander Sack', 'Xavier Lamien'
    ].each { |d| Mainteneur.create(:nom => d) }
  end

  def self.down
    Mainteneur.find(:all).each{ |d| d.destroy }
  end
end
