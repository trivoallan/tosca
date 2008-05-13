#!/usr/bin/env script/runner

require 'fastercsv'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'find'
require 'fileutils'


if ARGV[0]
  client_id = ARGV[0]
  client_name = Client.find(client_id).name
  puts "Would you like export informations for this client : #{client_name}? (yes / no)"
  reponse = $stdin.gets
  if reponse[0] != 121
    puts "Cancel"
    exit
  end
else
  puts "You must specify the client id"
  exit
end
puts "Export running..."


Dir.mkdir("./#{client_name}")

demandes = Client.find(client_id).demandes

demandes_csv = []
commentaires_csv = []
pj_csv = []

demandes_csv << ["id", "beneficiaire", "resume", "severite", "logiciel", "created_on", "typedemande", "statut de sortie"]
commentaires_csv << ["id", "demande_id", "piecejointe_id", "corps", "created_on", "déposeur"]
pj_csv << ["id", "name"]

demandes.each do |d|
  name_logiciel = d.logiciel ? d.logiciel.name : ""
  demandes_csv << [d.id, d.beneficiaire.user.name, d.resume, d.severite.name, name_logiciel, d.created_on, d.typedemande.name, d.statut.name]

  d.commentaires.find(:all, :conditions => { :prive => false }).each do |c|
    name_user = c.user.client? ? c.user.name : "Linagora"
    commentaires_csv << [c.id, c.demande_id, c.piecejointe_id, c.corps, c.created_on, name_user]
  end

  d.piecejointes.each do |p|
    pj_csv << [p.id, p.file_relative_path]
    Dir.mkdir("./#{client_name}/#{p.file_relative_path.split('/')[0]}")
    File.copy("files/piecejointe/file/#{p.file_relative_path}","#{client_name}/#{p.file_relative_path.split('/')[0]}")
  end
end


demandes_csv_string = FasterCSV.generate do |csv|
  demandes_csv.each do |d|
    csv << d
  end
end

commentaires_csv_string = FasterCSV.generate do |csv|
  commentaires_csv.each do |c|
    csv << c
  end
end

pj_csv_string = FasterCSV.generate do |csv|
  pj_csv.each do |p|
    csv << p
  end
end

myFile = File.open("#{client_name}/demandes.csv","w")
myFile.write(demandes_csv_string)
myFile.close


myFile = File.open("#{client_name}/commentaires.csv","w")
myFile.write(commentaires_csv_string)
myFile.close


myFile = File.open("#{client_name}/pjs.csv","w")
myFile.write(pj_csv_string)
myFile.close

Dossier_save = "#{client_name}" 
Fichier_zip = "#{client_name}.zip" 


Zip::ZipFile.open( Fichier_zip, Zip::ZipFile::CREATE ){ |zipfile|
  Find.find( Dossier_save ){ |find|
    # get relative path for the zip 
    dossier_base = find[ Dossier_save.length, find.length ] 
    if dossier_base != ""  
      if FileTest.directory?( find )  
        zipfile.dir.mkdir( dossier_base ) 
      else 
        zipfile.file.open( dossier_base, 'w' ){ |f| 
          f.write( File.open(find, 'rb').read ) 
        }
      end 
    end 
  }
  zipfile.close
}

FileUtils.remove_dir("#{client_name}")
