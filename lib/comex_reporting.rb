module  ComexReporting

  def init_comex_report
    @clients = Client.find(:all, :order => 'clients.nom')
    @requests = {}
    @requests[:last_week] = {}
    @requests[:new] = {}
    @requests[:closed] = {}
    @total = { :active=> {}, :final=> {} }
    @clients.each do |c|
      name = c.nom.intern
      @requests[:last_week][name] = [0,0,0,0, []]
      @requests[:new][name] = [0,0,0,0, []]
      @requests[:closed][name] = [0,0,0,0, []]
      @total[:active][name] = [0,0,0,0, []]
      @total[:final][name] = 0
    end
    @requests[:last_week][:total]=[0,0,0,0]
    @requests[:new][:total]=[0,0,0,0]
    @requests[:closed][:total]=[0,0,0,0]
    @total[:active][:total]=[0,0,0,0]
    @total[:final][:total]= 0
  end

  def compute_comex_report(client)
    name = client.nom.intern
    values = {
      :first_day => @date[:first_day],
      :last_day=> @date[:end_day],
      :beneficiaire_ids => client.beneficiaire_ids
    }
    cscopeTest = { :find => { :conditions => 
        [ 'beneficiaire_id IN (:beneficiaire_ids) ',values ] } 
    }
    Demande.with_scope(cscopeTest) {
      clast_week  = [ "created_on <= :first_day AND " << 
                      "(#{Demande::EN_COURS} OR " << 
                       "(#{Demande::TERMINEES} AND " << 
                         "updated_on >= :first_day " <<
                       "))", values ]
      @requests[:last_week][name][4] = 
        Demande.count(:group=> 'severite_id',:conditions => clast_week)

      cnew = [ 'created_on BETWEEN :first_day AND :last_day',values]
      @requests[:new][name][4] =
        Demande.count(:group => 'severite_id', :conditions => cnew)

      cclosed = [ 'updated_on BETWEEN :first_day AND :last_day AND ' <<
                  "#{Demande::TERMINEES}", values ]
      @requests[:closed][name][4] =
        Demande.count(:group => 'severite_id', :conditions => cclosed)
    }
    
    4.times do |i|
      last_week, closed, new = 0,0,0
      last_week= @requests[:last_week][name][4][i+1] if @requests[:last_week][name][4][i+1]
      closed = @requests[:closed][name][4][i+1] if @requests[:closed][name][4][i+1]
      new = @requests[:new][name][4][i+1] if @requests[:new][name][4][i+1]

      @total[:active][name][i] = last_week + new - closed
      @total[:final][name] += @total[:active][name][i]
      
      @requests[:last_week][:total][i] += last_week
      @requests[:new][:total][i] += new
      @requests[:closed][:total][i] += closed
      @total[:active][:total][i] += @total[:active][name][i]
    end
      @total[:active][name].map!{|x| x==0?nil:x}
      @total[:final][:total] += @total[:final][name]
  end
  def cns_correction
    @demandes= {}
    @percent = { :correction => {}, :contournement => {} }
    @contrats= Contrat.find(:all)
    @contrats.each do |contrat|
      @percent[:correction][contrat.id]= {}
      @percent[:contournement][contrat.id]= {}
      corrections= @percent[:correction][contrat.id]
      contournements = @percent[:contournement][contrat.id]

      support = contrat.client.support
      amplitude = support.fermeture - support.ouverture

      @demandes[contrat.id] = Demande.find :all,
             :conditions => Demande::EN_COURS, 
             :order=> 'updated_on ASC'
      demandes=@demandes[contrat.id]
      demandes.delete_if { |demand|
            demand.engagement( contrat.id) == nil
      }
      demandes.each do |demand|
        temps_ecoule = demand.temps_ecoule
        temps_correction = demand.engagement( contrat.id ).correction.days
        temps_contournement= demand.engagement(contrat.id).contournement.days

        temps_reel= 
          demand.distance_of_time_in_working_days(temps_ecoule, amplitude)
        temps_prevu_correction= 
          demand.distance_of_time_in_working_days(temps_correction,
                                                  amplitude)
        temps_prevu_contournement =
          demand.distance_of_time_in_working_days(temps_contournement,
                                                  amplitude)
        if temps_ecoule <= 0
          corrections[demand.id]=0
          contournements[demand.id]=0
        else
          corrections[demand.id]= (temps_reel/temps_prevu_correction )*100
          contournements[demand.id]= 
                  (temps_reel/temps_prevu_contournement )*100
        end
      end
    end
  end

end
