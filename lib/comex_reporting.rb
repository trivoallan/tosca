module  ComexReporting

  def init_comex_report
    @clients = Client.find(:all, :order => 'clients.nom')
    @requests = {}
    @requests[:last_week] = {}
    @requests[:new] = {}
    @requests[:closed] = {}
    @total = { :active=> {}, :final=> {} }
    @clients.each do |c|
      name = c.nom
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
    name = client.nom
    values = {
      :first_day => @date[:first_day],
      :last_day=> @date[:end_day],
      :beneficiaire_ids => client.beneficiaire_ids
    }
    cscopeTest = { :find => { :conditions =>
        [ 'demandes.beneficiaire_id IN (:beneficiaire_ids) ',values ] }
    }
    Demande.with_scope(cscopeTest) {
      clast_week  = [ "created_on <= :first_day AND " <<
                      "(#{Demande::EN_COURS} OR " <<
                       "(#{Demande::TERMINEES} AND " <<
                         "updated_on >= :first_day " <<
                       "))", values ]
      @requests[:last_week][name] = 
        Demande.count(:group=> 'severite_id',:conditions => clast_week)

      cnew = [ 'created_on BETWEEN :first_day AND :last_day',values]
      @requests[:new][name] =
        Demande.count(:group => 'severite_id', :conditions => cnew)

      cclosed = [ 'updated_on BETWEEN :first_day AND :last_day AND ' <<
                  "#{Demande::TERMINEES}", values ]
      @requests[:closed][name] =
        Demande.count(:group => 'severite_id', :conditions => cclosed)
    }

    4.times do |i|
      last_week, closed, new = 0,0,0
      last_week= @requests[:last_week][name][i+1] if @requests[:last_week][name][i+1]
      closed = @requests[:closed][name][i+1] if @requests[:closed][name][i+1]
      new = @requests[:new][name][i+1] if @requests[:new][name][i+1]

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
    @percents, @extra = [], []

    contrats= Contrat.find(:all, :order => 'id ASC')
    contrats.each do |contrat|
      c = @percents[contrat.id]= []
      c_extra = @extra[contrat.id] = {}
      c_extra[:nom], c_extra[:demandes_ids] = contrat.nom, []

      demandes = Demande.find :all,
        :conditions => Demande::EN_COURS, :order=> 'updated_on ASC'
      demandes.delete_if { |request|
        engagement= request.engagement(contrat.id)
        engagement == nil or request.paquets.empty? or
        request.paquets.first.contrat != contrat or
        ( engagement.correction < 0 and engagement.contournement < 0 )
      }
      demandes.each do |request|
        c_extra[:demandes_ids].push( request.id )
        d = c[request.id]= {}
        d[:resume]= request.resume
        # temps_ecoule en seconde mais prend en compte les horaire de travail
        # temps_ecoule is in seconds, but take into consideration the working days
        temps_ecoule = request.temps_ecoule
        if temps_ecoule < 0
          d[:correction], d[:contournement] = 0,0
          d[:mesg_correction], d[:mesg_contournement] ='-', '-'
        else
        # temps_correction and temps_contournement are in second, and not null
          temps_correction = request.engagement(contrat).correction.days
          temps_contournement= request.engagement(contrat).contournement.days
          d[:mesg_correction]=  request.distance_of_time_in_french_words( 
            (temps_correction - temps_ecoule).abs, request.client.support )
          d[:mesg_contournement] = request.distance_of_time_in_french_words( 
            (temps_contournement-temps_ecoule).abs, request.client.support )
          d[:correction]=  (temps_ecoule/temps_correction )*100
          d[:contournement]= (temps_ecoule/temps_contournement )*100
        end
      end
      c_extra[:demandes_ids].sort!{|a,b| c[a][:correction] <=> c[b][:correction] }.reverse!
    end
    delete_empty_contracts
  end
  def delete_empty_contracts
    @percents.compact!
    @extra.compact!
    @percents.delete_if { |c| c.empty? }
    @extra.delete_if { |c_extra|
      c_extra[:demandes_ids].empty?
    }
  end

end
