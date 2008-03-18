sudo chown -R mloiseleur:mloiseleur *
rake tmp:clear
cvs up
rake makemo
rake db:migrate
sudo chown -R www-data:www-data *
sudo /etc/init.d/mongrel_cluster restart 

