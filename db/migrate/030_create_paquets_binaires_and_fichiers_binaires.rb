class CreatePaquetsBinairesAndFichiersBinaires < ActiveRecord::Migration
  def self.up
    transaction do
      change_column :fichiers, :chemin, :string

      create_table :paquets_binaires do |t|
        t.column :paquet_id, :integer, :null => false
        t.column :arch_id, :integer, :null => false
        t.column :nom, :string
        t.column :configuration, :text
      end
      add_index :paquets_binaires, :paquet_id
      add_index :paquets_binaires, :arch_id

      create_table :fichiers_binaires do |t|
        t.column :paquet_binaire_id, :integer
        t.column :chemin, :string
        t.column :taille, :integer
      end
      add_index :fichiers_binaires, :paquet_binaire_id

      # insertion des paquets binaires
      insert('INSERT INTO paquets_binaires(paquet_id,arch_id,nom) ' + 
               'SELECT id, arch_id, nom FROM paquets where arch_id <> 6;')
      # insertions des fichiers associés
      insert('INSERT INTO fichiers_binaires(paquet_binaire_id,chemin,taille) ' + 
               'SELECT pb.id, f.chemin, f.taille ' +
               'FROM fichiers f INNER JOIN paquets_binaires pb ' +
               'ON pb.paquet_id=f.paquet_id;')
      # mis à jour des liens vers les paquets sources
      update('UPDATE paquets_binaires pb SET pb.paquet_id = ' +
               '(SELECT p_src.id FROM paquets p_src, paquets p_bin '+ 
               'WHERE pb.paquet_id=p_bin.id AND ' + 
               'p_src.logiciel_id=p_bin.logiciel_id AND ' + 
               'p_src.version=p_bin.version AND p_src.release=p_bin.release ' + 
               'AND p_src.socle_id=p_bin.socle_id AND p_src.arch_id=6 LIMIT 1);')
      # nettoyage des paquets sans source
      delete('DELETE FROM paquets_binaires WHERE paquet_id = 0;')
      # nettoyage des paquets binaires de la table des paquets sources
      delete('DELETE FROM paquets WHERE arch_id <> 6;')
      # nettoyage des fichiers
      delete('DELETE FROM fichiers WHERE paquet_id NOT IN ' +
               '(SELECT id FROM paquets);')
      # on peut enfin se débarrasser de l'arch :)
      remove_column :paquets, :arch_id
    end
  end

  def self.down
    field = [ 'logiciel_id','nom','version','release','conteneur_id',
      'paquet_id','distributeur_id','mainteneur_id','contrat_id',
      'socle_id','taille','fournisseur_id','configuration' ]
    insert_columns = field.join(',')
    field.each_index { |i| field[i] = "p.#{field[i]}" }
    select_columns = field.join(',')
    transaction do
      add_column :paquets, :arch_id, :integer
      add_column :paquets, :paquet_binaire_id, :integer
      add_index :paquets, :paquet_binaire_id
      update('UPDATE paquets SET arch_id=6;')
      insert('INSERT INTO paquets(paquet_binaire_id,arch_id,' + insert_columns + ') ' +
               'SELECT pb.id, pb.arch_id, ' + select_columns + ' ' +
               'FROM paquets_binaires pb INNER JOIN paquets p ' +
               'ON pb.paquet_id=p.id')
      insert('INSERT INTO fichiers (paquet_id,chemin,taille) ' +
               'SELECT p.id, fb.chemin, fb.taille ' +
               'FROM fichiers_binaires fb INNER JOIN paquets p ' +
               'ON fb.paquet_binaire_id=p.paquet_binaire_id')
      remove_column :paquets, :paquet_binaire_id
      drop_table :fichiers_binaires
      drop_table :paquets_binaires
    end
  end
end
