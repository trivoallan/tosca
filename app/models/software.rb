#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
class Software < ActiveRecord::Base
  acts_as_taggable

  has_one :image, :dependent => :destroy
  belongs_to :license
  belongs_to :groupe

  has_many :contributions
  has_many :knowledges
  has_many :issues
  has_many :urlsoftwares, :dependent => :destroy,
    :order => 'urlsoftwares.typeurl_id'
  has_many :releases, :through => :versions
  has_many :versions, :order => "versions.name DESC", :dependent => :destroy

  has_and_belongs_to_many :competences, :uniq => true

  validates_presence_of :name, :message =>
    _('You have to specify a name')
  validates_presence_of :groupe, :message =>
    _('You have to specify a group')
  validates_length_of :competences, :minimum => 1, :message =>
    _('You have to specify at least one technology')

  # See ApplicationController#scope
  def self.set_public_scope()
    self.scoped_methods << { :find => { :conditions =>
        { :private => false } } }
  end

  # TODO : l'une des deux est de trop. Normalement c'est
  # uniquement content_columns
  def self.list_columns
    columns.reject { |c| c.primary ||
        c.name =~ /(_id|name|resume|description|referent)$/ ||
          c.name == inheritance_column }
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c|
      c.primary || c.name =~ /(_id|_count|referent|Description)$/
    }
  end

  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end

  ReleasesContract = Struct.new(:name, :id, :type)
  # Returns all the version and the last release of each version
  # Returns Array of ContractReleases
  # Call it like : Software.first.releases_contract(Contract.first.id)
  def releases_contract(contract_id)
    result = []
    self.versions.find(:all,
      :conditions => { "contracts.id" =>  contract_id },
      :joins => :contracts, :group => "versions.id").each do |v|
      releases = v.releases
      if releases.empty?
        result.push ReleasesContract.new(v.full_name, v.id, Version)
      else
       r = releases.sort!.first
       result.push ReleasesContract.new(r.full_name, r.id, Release)
      end
    end
    result
  end

  include Comparable
  def <=>(other)
    self.name <=> other.name
  end

end
