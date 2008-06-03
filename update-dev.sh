sudo chown -R mloiseleur:mloiseleur *
rake tmp:clear
rake log:clear
cvs up
rake db:migrate
rake l10n:mo
./script/runner update-db.rb
sudo chown -R www-data:www-data *
sudo /etc/init.d/mongrel_cluster restart
