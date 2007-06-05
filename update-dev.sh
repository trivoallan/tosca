sudo chown -R mloiseleur:mloiseleur *
rake tmp:clear
cvs up
rake makemo
rake db:migrate
mkdir -p public/images/reporting
sudo chown -R www-data:www-data *
sudo /etc/init.d/mongrel_cluster restart 

