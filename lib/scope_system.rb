module Scope

  private
  # There is a global scope, on all finders, in order to
  # preserve each user in his particular space.
  # TODO : scope contract only ?? it seems coherent...
  SCOPE_CLIENT = [ Client, Document, Socle ]
  SCOPE_CONTRACT = [ Binaire, Contract, Demande, Paquet, Phonecall ]

  # This method has a 'handmade' scope, really faster and with no cost
  # of safety. It was made in order to avoid 15 yields.
  def define_scope(user, is_connected)
    if is_connected
      beneficiaire, ingenieur = user.beneficiaire, user.ingenieur
      apply = ((ingenieur and user.restricted?) || beneficiaire)
      if apply
        contract_ids = user.contract_ids
        client_ids = user.client_ids
        if contract_ids.empty?
          contract_ids = [ 0 ]
          client_ids = [ beneficiaire.client_id ] if beneficiaire
        end
        SCOPE_CONTRACT.each {|m| m.set_scope(contract_ids) }
        SCOPE_CLIENT.each {|m| m.set_scope(client_ids) }
      end
    else
      # Forbid access to request if we are not connected. It's just a paranoia.
      Demande.set_scope([0])
    end
    begin
      yield
    ensure
      if is_connected
        if apply
          SCOPE_CLIENT.each { |m| m.remove_scope }
          SCOPE_CONTRACT.each { |m| m.remove_scope }
        end
      else
        Demande.remove_scope
      end
    end
  end

end
