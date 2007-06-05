sudo chown -R mloiseleur:niveau3 *
mkdir -p public/images/reporting
rake tmp:clear
cvs up
rake makemo
rake db:migrate
sudo chown -R www-data:www-data *
sudo /etc/init.d/mongrel_cluster restart


