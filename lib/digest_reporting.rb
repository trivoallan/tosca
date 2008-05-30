module DigestReporting

  #contract is a Contrat, requests is an array of DigestRequests
  DigestContrats = Struct.new(:contract, :requests)
  #request is a Demande, request_at is a Demande, comments is an array of Commentaire
  DigestRequests = Struct.new(:request, :request_at, :comments)

  def digest_result(period)
    @period = period
    @period = "year" if period.blank?
    updated = Time.now.send("beginning_of_#{@period}")
    # We must localise it after getting the (english) helper for the start date
    @period = _(@period)

    options = { :conditions => [ "updated_on >= ? ", updated ],
     :order => "contrat_id ASC", :include => [:typedemande, :severite, :statut]}
    requests = Demande.find(:all, options)

    @result = Array.new
    last_contrat_id = nil
    requests.each do |r|
      if last_contrat_id != r.contrat_id
        dc = DigestContrats.new
        dc.contract = r.contrat
        dc.requests = Array.new
        @result.push(dc)
      end

      options = { :conditions => [ "created_on >= ? ", updated ] }

      dr = DigestRequests.new
      dr.request = r
      dr.request_at = r.state_at(updated)
      dr.comments = r.commentaires.find(:all, options)
      @result.last.requests.push(dr)

      last_contrat_id = r.contrat_id
    end
  end

  #important is an array of Demande, other is an array of DigestContrats
  DigestManagers = Struct.new(:important, :other)

  def digest_managers(period)
    @period = period
    @period = "year" if period.blank?
    updated = Time.now.send("beginning_of_#{@period}")
    # We must localise it after getting the (english) helper for the start date
    @period = _(@period)
    
    options = { :conditions => [ "updated_on >= ? ", updated ],
     :order => "contrat_id ASC", :include => [:typedemande, :severite, :statut]}
    requests = Demande.find(:all, options)
    
    @result = DigestManagers.new    
    @result.important = Array.new
    @result.other = Array.new
    last_contrat_id = nil
    requests.each do |r|
      if last_contrat_id != r.contrat_id and not r.critical?
        dc = DigestContrats.new
        dc.contract = r.contrat
        dc.requests = Array.new
        @result.other.push(dc)
      end
      
      if r.critical?
        @result.important.push(r)
      else 
 
        options = { :conditions => [ "created_on >= ? ", updated ] }

        dr  = DigestRequests.new
        dr.request = r
        dr.request_at = r.state_at(updated)
        dr.comments = r.commentaires.find(:all, options)
        @result.other.last.requests.push(dr)
      end

      last_contrat_id = r.contrat_id
    end

  end

end