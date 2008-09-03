class Contribution < ActiveRecord::Base
  has_one :demande
  has_many :urlreversements

  belongs_to :typecontribution
  belongs_to :etatreversement
  belongs_to :logiciel
  belongs_to :ingenieur

  belongs_to :affected_version, :class_name => "Version"
  belongs_to :fixed_version, :class_name => "Version"

  file_column :patch, :fix_file_extensions => nil

  validates_length_of :name, :within => 3..100
  validates_presence_of :logiciel,
    :warn => _('You have to specify a software.')

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|_on|^patch)$/ || c.name == inheritance_column }
  end

  def to_s
    return name unless patch
    index = patch.rindex('/')+ 1
    patch[index..-1]
  end

  def fragments
    [ %r{contributions/select_(\d*|all)} ]
  end

  def summary
    out = ''
    out << typecontribution.name + _(' on ') if typecontribution
    out << logiciel.name
    out << " #{affected_version}" if affected_version
    out
  end

  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end

  # date de reversement formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def contributed_on_formatted
    contributed_on = read_attribute(:contributed_on)
    return '' unless contributed_on
    display_time contributed_on
  end

  # date de cloture formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def closed_on_formatted
    closed_on = read_attribute(:closed_on)
    return '' unless closed_on
    display_time closed_on
  end

  # délai (en secondes) entre la déclaration et l'acceptation
  # delai_to_s (texte)
  # en jours : sec2day(delai)
  def delay
    if closed_on? and contributed_on?
      (closed_on - contributed_on)
    else
      -1
    end
  end
  
  # Fake fields, used to prettify _form WUI
  def reverse; contributed_on?; end
  def clos; closed_on?; end
  def clos=(fake); end
  def reverse=(fake); end

end
