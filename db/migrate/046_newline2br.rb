class Newline2br < ActiveRecord::Migration

  def self.up
    update("UPDATE demandes SET description=REPLACE(description,'\n','<br/>')")
    update("UPDATE clients SET description=REPLACE(description,'\n','<br/>')")
    update("UPDATE clients SET adresse=REPLACE(adresse,'\n','<br/>')")
    update("UPDATE machines SET description=REPLACE(description,'\n','<br/>')")
    update("UPDATE statuts SET description=REPLACE(description,'\n','<br/>')")
    update("UPDATE logiciels SET description=REPLACE(description,'\n','<br/>')")
    update("UPDATE commentaires SET corps=REPLACE(corps,'\n','<br/>')")
  end

  def self.down
    update("UPDATE demandes SET description=REPLACE(description,'<br/>','\n')")
    update("UPDATE clients SET description=REPLACE(description,'<br/>','\n')")
    update("UPDATE clients SET adresse=REPLACE(adresse,'<br/>','\n')")
    update("UPDATE machines SET description=REPLACE(description,'<br/>','\n')")
    update("UPDATE statuts SET description=REPLACE(description,'<br/>','\n')")
    update("UPDATE logiciels SET description=REPLACE(description,'<br/>','\n')")
    update("UPDATE commentaires SET corps=REPLACE(corps,'<br/>','\n')")

  end
end
