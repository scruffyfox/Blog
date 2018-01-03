This is really just for me to use to get new rails apps on Plesk. May be helpful to you, may not, but im certinally no pro at rails.

## Prerequisites
1. Passenger to be installed
2. RVM to be installed
3. Gems and rails 3.x to be installed

Firstly create a new subdomain/domain for the app and upload all of your rails files.

Next we go to the vhosts directory. There should be a folder for your domain/subdomain. For example `blog.callumtalyor.net`

CD into `config` and create a new file called `vhosts.conf` and paste this 

```
  ServerName blog.callumtaylor.net
   # !!! Be sure to point DocumentRoot to 'public'!
   DocumentRoot /var/www/vhosts/callumtaylor.net/blog/public
   <Directory /var/www/vhosts/callumtaylor.net/blog/public>
      # This relaxes Apache security settings.
      AllowOverride all
      # MultiViews must be turned off.
      Options -MultiViews
   </Directory>
```

where `blog.callumtaylor.net` is your domain root and `var/www/vhosts/callumtaylor.net/blog/public` is where your public folder is on the file system.

Next we reconfigure the domain using `sudo /usr/local/psa/admin/sbin/httpdmng --reconfigure-domain blog.callumtaylor.net` and restart apache `sudo /etc/init.d/apache2 restart`, touch the restart.txt file `touch /var/www/vhosts/callumtaylor.net/blog/tmp/restart.txt` and job's a gooden.