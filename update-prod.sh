sudo chown -R mloiseleur:niveau3 *
mkdir -p public/images/reporting
rake tmp:clear
rake makemo
cvs up
sudo chown -R www-data:www-data *
sudo /etc/init.d/apache2 reload

