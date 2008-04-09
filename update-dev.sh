sudo chown -R mloiseleur:mloiseleur *
rake tmp:clear
rake log:clear
cvs up
sudo rm -Rf vendor/plugins/tiny_mce_gzip/
rake makemo

#! update-db.sh
export RAILS_ENV=production
echo "Demande.connection.connection.query('UPDATE schema_info SET version = 1')" | ./script/console
rake db:migrate
./script/runner update-db.rb
rake makemo
sudo chown -R www-data:www-data *
sudo /etc/init.d/mongrel_cluster restart
