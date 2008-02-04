module  ComexReporting

  def init_comex_report
    @clients = Client.find(:all, :order => 'clients.name')
    @requests = {}
    @requests[:last_week] = {}
    @requests[:new] = {}
    @requests[:closed] = {}
    @total = { :active=> {}, :final=> {} }
    @clients.each do |c|
      name = c.name.intern
      @total[:active][name] = [0,0,0,0, []]
      @total[:final][name] = 0
    end
    @requests[:last_week][:total]=[0,0,0,0]
    @requests[:new][:total]=[0,0,0,0]
    @requests[:closed][:total]=[0,0,0,0]
    @total[:active][:total]=[0,0,0,0]
    @total[:final][:total]= 0
  end


  # used internally by compute_comex_report 4 getting all request
  # ids of previously opened request. There is some similarity with
  # get_closed_condition4comex_report
  # /!\ you do NOT want to use it elsewhere. /!\
  # date_condition looks like : "created_on < '#{date.to_formatted_s(db)}'"
  # remove_array : contains entries which will be removed if they matches
  #                using <tt>.include?</tt> method
  def get_last_condition4comex_report(cdate, remove_array)
    cselect = "demandes.id, (SELECT c.statut_id FROM commentaires c WHERE " <<
      "(#{cdate}) AND c.demande_id = " <<
      "demandes.id AND c.statut_id IS NOT NULL " <<
      "ORDER BY c.created_on DESC LIMIT 1 ) statut_id"
    requests = Demande.find(:all, :select => cselect, :conditions => cdate)
    # TODO : .include? is too slow. A hash or something better ?
    requests = requests.delete_if { |d| d.statut_id.nil? or remove_array.include? d.statut_id }
    request_ids = requests.collect { |d| d.id }

    { :group => 'severite_id',
      :conditions => ["demandes.id IN (?)", request_ids ] }
  end

  # used internally by compute_comex_report 4 getting all request
  # ids of closed req during com_date. req_date is used to reduce the
  # perimeter of possible requests. There is some similarity with
  # get_last_condition4comex_report
  # /!\ you do NOT want to use it elsewhere. /!\
  # req_date : "created_on < '#{date.to_formatted_s(db)}'"
  # com_date : "created_on < '#{date.to_formatted_s(db)}'"
  # remove_array : contains entries which will be removed if they matches
  #                using <tt>.include?</tt> method
  def get_closed_condition4comex_report(com_date, req_date, remove_array)
    cselect = "demandes.id, (SELECT c.id FROM commentaires c WHERE " <<
      "(#{com_date}) AND c.demande_id = " <<
      "demandes.id AND c.statut_id IS NOT NULL " <<
      "ORDER BY c.created_on DESC LIMIT 1 ) commentaire_id"
    requests = Demande.find(:all, :select => cselect, :conditions => req_date)
    # TODO : .include? is too slow. A hash or something better ?
    requests = requests.delete_if { |d| d.commentaire_id.nil? }
    requests.delete_if { |r|
      result = false
      comm = Commentaire.find(r.commentaire_id)
      result = remove_array.include? comm.statut_id
      # We need to check if it's a closed -> closed change
      # or a opened -> closed change
      # If you have a better idea, just do it and erase this crap.
      unless result
        options = { :conditions =>
          [ 'commentaires.demande_id = ? AND commentaires.created_on < ? AND commentaires.statut_id IS NOT NULL',
            comm.demande_id, comm.created_on ], :order => 'created_on DESC' }
        previous_comm = Commentaire.find(:first, options)
        result = !remove_array.include?(previous_comm.statut_id)
      end
      result
    }
    request_ids = requests.collect { |d| d.id }

    { :group => 'severite_id',
      :conditions => ["demandes.id IN (?)", request_ids ] }
  end


  def compute_comex_report(client)
    name = client.name.intern
    values = {
      :first_day => @date[:first_day],
      :last_day=> @date[:end_day],
      :beneficiaire_ids => client.beneficiaire_ids
    }
    client_scope = { :find => { :conditions =>
        [ 'demandes.beneficiaire_id IN (:beneficiaire_ids) ',values ] }
    }
    Demande.send(:with_scope, client_scope) {
      first_day = values[:first_day].to_formatted_s(:db)
      last_day = values[:last_day].to_formatted_s(:db)

      # TODO : keep request_id when search closed request. It can be
      # clearly faster, without forgetting to add newly created_request.
      before_date = "created_on <= '#{first_day}'"
      clast_week = get_last_condition4comex_report(before_date, Statut::CLOSED)
      @requests[:last_week][name] = Demande.count(clast_week)

      cnew = [ 'created_on BETWEEN :first_day AND :last_day',values]
      @requests[:new][name] =
        Demande.count(:group => 'severite_id', :conditions => cnew)

      between_date = "created_on BETWEEN '#{first_day}' AND '#{last_day}'"
      before_date = "created_on <= '#{last_day}'"
      cclosed = get_closed_condition4comex_report(between_date, before_date, Statut::OPENED)
      @requests[:closed][name] = Demande.count(cclosed)
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
      c_extra[:name], c_extra[:demandes_ids] = contrat.name, []

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
        # elapsed_time is in seconds, but take into consideration the working days
        elapsed_time = request.temps_ecoule
        d[:correction], d[:contournement] = 0,0
        d[:mesg_correction], d[:mesg_contournement] ='-', '-'
        if elapsed_time >= 0
        # correction_time and workaround_time are in second, and not null
          correction_time = request.engagement(contrat).correction.days
          workaround_time = request.engagement(contrat).contournement.days
          unless correction_time == -1.day
            d[:mesg_correction]=  request.distance_of_time_in_french_words(
              (correction_time - elapsed_time).abs, request.contrat )
            d[:correction]=  (elapsed_time/correction_time )*100
          end
          unless workaround_time == -1.day
            d[:mesg_contournement] = request.distance_of_time_in_french_words(
              (workaround_time-elapsed_time).abs, request.contrat )
            d[:contournement]= (elapsed_time/workaround_time )*100
          end
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
