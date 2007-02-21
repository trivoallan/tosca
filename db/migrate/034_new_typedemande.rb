#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class NewTypedemande < ActiveRecord::Migration
  def self.up
    Typedemande.create(:nom => 'Monitorat')
    Typedemande.create(:nom => 'Intervention')
    Typedemande.create(:nom => 'Etude')
  end

  def self.down
    Typedemande.find_by_nom('Monitorat').destroy
    Typedemande.find_by_nom('Intervention').destroy
    Typedemande.find_by_nom('Etude').destroy
  end
end
