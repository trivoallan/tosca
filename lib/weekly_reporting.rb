module WeeklyReporting

  # Give the status of requests flow during a certain time,
  # specified from @date[:first_day] to @date[:end_day]
  def compute_weekly_report(beneficiaire_ids)
    values = {
      :first_day => @date[:first_day],
      :last_day=> @date[:end_day],
      :beneficiaire_ids => beneficiaire_ids
    }
    scope = { :find => { :conditions =>
        [ 'demandes.beneficiaire_id IN (:beneficiaire_ids) AND demandes.updated_on BETWEEN :first_day AND :last_day', values ] }
    }
    Demande.send(:with_scope, scope) {
      first_day = values[:first_day].to_formatted_s(:db)
      last_day = values[:last_day].to_formatted_s(:db)

      options = { :conditions =>
        [ 'demandes.created_on BETWEEN :first_day AND :last_day', values ],
        :order => 'clients.name, demandes.id', :include => [{:beneficiaire => :client},
                                                           :statut,:typedemande] }
      @requests_created = Demande.find(:all, options)

      options[:conditions] = [ 'demandes.statut_id = ?', 7 ] # 7 => Closed.
      @requests_closed = Demande.find(:all, options)

      options[:conditions] = [ 'demandes.statut_id = ?', 8 ] # 8 => Cancelled.
      @requests_cancelled = Demande.find(:all, options)
    }
  end
end
