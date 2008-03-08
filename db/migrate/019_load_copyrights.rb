class LoadCopyrights < ActiveRecord::Migration
  class License < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Licenses
    return unless License.count == 0

    # Sample OS License
    [ [ 'BSD', 'http://www.edgewall.com/trac/license.html' ],
      [ 'GPL', 'http://www.gnu.org/copyleft/gpl.html' ],
      [ 'LGPL', 'http://www.gnu.org/copyleft/lgpl.html' ],
      [ 'MPL', 'http://www.mozilla.org/MPL/' ]
    ].each { |l| License.create(:nom => l.first, :url => l.last,
                                :certifie_osi => true) }
  end

  def self.down
    License.find(:all).each{ |l| l.destroy }
  end
end
