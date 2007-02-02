sudo chown -R mloiseleur:mloiseleur *
rake tmp:clear
cvs up
mkdir -p public/images/reporting
sudo chown -R www-data:www-data *
sudo /etc/init.d/apache2 restart

