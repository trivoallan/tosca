module Scope

  private
  # There is a global scope, on all finders, in order to
  # preserve each user in his particular space.
  # TODO : scope contract only ?? it seems coherent...
  # This method has a 'handmade' scope, really faster and with no cost
  # of safety. It was made in order to avoid 15 yields.
  def define_scope(user, is_connected)
    # defined locally since this file is loaded by application controller
    # it reduces dramatically loading time
    @@scope_client ||= [ Client, Document ]
    @@scope_contract ||= [ Release, Contract, Demande, Phonecall ]
    if is_connected
      recipient, ingenieur = user.recipient, user.ingenieur
      apply = ((ingenieur and user.restricted?) || recipient)
      if apply
        contract_ids = user.contract_ids
        client_ids = user.client_ids
        if contract_ids.empty?
          contract_ids = [ 0 ]
          client_ids = [ recipient.client_id ] if recipient
        end
        @@scope_contract.each {|m| m.set_scope(contract_ids) }
        @@scope_client.each {|m| m.set_scope(client_ids) }
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
          @@scope_client.each { |m| m.remove_scope }
          @@scope_contract.each { |m| m.remove_scope }
        end
      else
        Demande.remove_scope
      end
    end
  end

end
