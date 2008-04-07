sudo chown -R mloiseleur:mloiseleur *
rake tmp:clear
rake log:clear
cvs up
sudo rm -Rf vendor/plugins/tiny_mce_gzip/
rake makemo

#! update-db.sh
export RAILS_ENV=production

echo "User.find(:all).each {|u| u.update_attribute :email, 'mloiseleur@linagora.com'}; puts" | ./script/console
echo "Contrat.find(:all).each {|c| c.update_attribute :mailinglist, 'mloiseleur@linagora.com' }; puts" | ./script/console
echo "Demande.find(:all).each {|d| d.update_attribute :mail_cc, nil }; puts" | ./script/console

rake db:migrate
sudo chown -R www-data:www-data *
sudo /etc/init.d/mongrel_cluster restart 

