# Il faut ajouter un "| xargs cvs add", apres voir vérifié que ça passe
cvs up | sed 's/\? //g' | grep -v "^M " | grep -v "^tmp" | grep -v "^log" | grep -v "^public" | grep -v "^A "
