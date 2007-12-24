class LoadPackagers < ActiveRecord::Migration
  class Mainteneur < ActiveRecord::Base; end

  def self.up
    [ '(none)', 'Anthony Mercatante', 'Emmanuel Seyman', 'Michel Loiseleur',
      'Dag Wieers', 'Alexander Sack'
    ].each { |d| Mainteneur.create(:nom => d) }
  end

  def self.down
    Mainteneur.find(:all).each{ |d| d.destroy }
  end
end
