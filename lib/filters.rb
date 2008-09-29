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
module Filters

  module Shared
    def self.extended(base)
      base.class_eval do
        define_method(:initialize) { |params, *args|
          if params.is_a? Hash
            params.each {|key, value|
              if key =~ /_id/ and value.is_a? String and not value.blank?
                send("#{key}=", value.to_i)
              else
                send("#{key}=", value)
              end
            }
          else
            super(*args.unshift(params))
          end
        }
      end
    end
  end

  class Knowledges < Struct.new('Knowledges', :ingenieur_id,
                                :software_id, :competence_id)
    extend Shared
  end

  class Contributions < Struct.new('Contributions', :software, :ingenieur_id,
                             :contribution, :etatreversement_id, :contract_id)
    extend Shared
  end

  class Softwares < Struct.new('Softwares', :software, :groupe_id,
                               :contract_id, :description )
    extend Shared
  end

  class Calls < Struct.new('Calls', :ingenieur_id, :recipient_id,
                            :contract_id, :after, :before)
    extend Shared
  end

  class Clients < Struct.new('Clients', :text, :system_id, :active)
    extend Shared
  end

  class Issues < Struct.new('Issues', :text, :contract_id, :ingenieur_id,
                              :typeissue_id, :severite_id, :statut_id,
                              :active, :limit)
    extend Shared
  end

  class Accounts < Struct.new('Accounts', :name, :client_id, :role_id)
    extend Shared
  end

  # build the conditions query, from a well specified array of filters
  # Specification of a filter f :
  # [ namespace, field, database field, operation ]
  # And params[f[0]][f[1]] contains the value searched
  # <hr />
  # There are 3 kind of operation, expressed in symbol
  # :like, :in & :equal
  # Call it like :
  # conditions = Filters.build_conditions(params, [
  #   ['software', 'name', 'versions.name', :like ],
  #   ['software', 'description', 'versions.description', :like ],
  #   ['filters', 'groupe_id', 'softwares.groupe_id', :equal ],
  #   ['filters', 'knowledge_id', 'competences_softwares.competence_id', :equal ],
  #   ['filters', 'client_id', ' versions.contract_id', :in ]
  # ])
  # flash[:conditions] = options[:conditions] = conditions
  # This helpers is here mainly for avoiding SQL injection.
  # you MUST use it, if you don't want to burn in hell during your seven next lives
  # special_conditions allows to put additional conditions to the filters.
  # it must be a string !
  # TODO : rework this helper in order to avoid the :dual_like hacks.
  def self.build_conditions(params, filters, special_conditions = nil)
    conditions = [[]]
    condition_0 = conditions.first
    filters.each { |f|
      value = params[f.first]
      unless value.blank?
        query = case f.last
                when :equal
                  "#{f[1]}=?"
                when :greater_than
                  "#{f[1]}>?"
                when :lesser_than
                  "#{f[1]}<?"
                when :dual_like
                  "(#{f[1]} LIKE (?) OR #{f[2]} LIKE (?))"
                else
                  "#{f[1]} #{f[2]} (?)"
                end
        condition_0.push query
        # now, fill in parameters of the query
        case f.last
        when :like
          conditions.push "%#{value}%"
        when :dual_like
          temp = "%#{value}%"
          conditions.push temp, temp
        else
          conditions.push value
        end
      end
    }
    condition_0.push special_conditions if special_conditions.is_a? String
    if condition_0.empty?
      nil
    else
      conditions[0] = condition_0.join(' AND ')
      conditions
    end
  end
end
