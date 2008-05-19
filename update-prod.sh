sudo chown -R mloiseleur:niveau3 *
rake tmp:clear
cvs up
rake db:migrate
rake makemo
sudo chown -R www-data:www-data *
sudo /etc/init.d/mongrel_cluster restart


