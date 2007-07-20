module Filters

  # build the conditions query, from a well specified array of filters
  # Specification of a filter f :
  # [ namespace, field, database field, operation ]
  # And params[f[0]][f[1]] contains the value searched
  # <hr />
  # There are 3 kind of operation, expressed in symbol
  # :like, :in & :equal
  # Call it like : 
  # conditions = Filters.build_conditions(params, [
  #   ['logiciel', 'nom', 'paquets.nom', :like ],
  #   ['logiciel', 'description', 'paquets.description', :like ],
  #   ['filters', 'groupe_id', 'logiciels.groupe_id', :equal ],
  #   ['filters', 'competence_id', 'competences_logiciels.competence_id', :equal ],
  #   ['filters', 'client_id', ' paquets.contrat_id', :in ] 
  # ])
  # flash[:conditions] = options[:conditions] = conditions 
  # This helpers is here mainly for avoiding SQL injection.
  # you MUST use it, if you don't want to burn in hell during your seven next lives
  # special_conditions allows to put additional conditions to the filters.
  # it must be a string !
  # TODO : rework this helper in order to avoid the :dual_like hacks.
  def self.build_conditions(params, filters, special_conditions = nil)
    conditions = [[]]
    filters.each { |f|
      if params[f.first] 
        value = params[f.first][f[1]] 
        unless value.blank?
          query = case f.last
                  when :equal
                    "#{f[2]}=?"
                  when :greater_than
                    "#{f[2]}>?"
                  when :lesser_than
                    "#{f[2]}<?"
                  when :dual_like
                    "(#{f[2]} LIKE (?) OR #{f[3]} LIKE (?))"
                  else
                    "#{f[2]} #{f[3]} (?)"
                  end
          conditions[0].push query 
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
      end
    }
    conditions.first.push special_conditions if special_conditions.is_a? String
    if conditions.first.empty?
      nil
    else
      conditions[0] = conditions.first.join(' AND ') 
      conditions
    end
  end
end
