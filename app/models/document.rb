#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Document < ActiveRecord::Base
  belongs_to :client
  belongs_to :typedocument
  belongs_to :identifiant
  file_column :fichier, :fix_file_extensions => nil


  #versioning, qui s'occupe de la table documents_versions
  acts_as_versioned
  validates_length_of :titre, :within => 3..60


  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions => 
        [ 'documents.client_id IN (?)', client_ids ] } }
  end

  def updated_on_formatted
    d = @attributes['updated_on']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} #{d[11,2]}:#{d[14,2]}"
  end
  def date_delivery_on_formatted
    return '-' unless date_delivery
    d = @attributes['date_delivery']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} "
  end

  def nomfichier
    return fichier[/[._ \-a-zA-Z0-9]*$/] if fichier
  end

  def to_param
    "#{id}-#{titre.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def self.content_columns 
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|fichier)$/ || c.name == inheritance_column } 
  end

end
