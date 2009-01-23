# Permet d'afficher les nouveaux fichiers. 
# Après vérification, un '| xargs cvs add' permet d'ajouter
# Dans l'ordre :
# on enlève les '? '
# on enlève ceux qui sont déjà ajoutés
# on enlève les répertoires temporaires, de log ou public

cvs up | sed 's/\? //g' | grep -v '^A' | grep -v "^M " | grep -v "^tmp" | grep -v "^log" | grep -v "^public" | sed -e 's/^\(.*\)/"\1"/' 
