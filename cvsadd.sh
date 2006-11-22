cvs up | sed 's/\? //g' | grep -v "^M " | grep -v "^tmp" | grep -v "^log" | grep -v "^public"
