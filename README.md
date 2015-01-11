# Minecraft Backup Bootstrap

This is a simple-hacky-lightweight script that monitors & parses `AromaBackup-1.6.4-0.0.0.0.1.jar`'s `backupstore.txt`. Inotify is used to monitor the file. As a result it only rebuilds the index when a new backup is added -- not on every http request.

    $ bundle install
    $ ./backups.rb


Here is an example upstart script that will keep the backup monitoring script running. Replace `USER:GROUP` with approperate values, and modify paths as desired.


/etc/init/minecraft-backup-index.conf
```upstart
#!upstart
description "Monitor Minecraft Backups & Rebuild Index"
start on startup
stop on shutdown

respawn

exec start-stop-daemon --start --chuid USER:GROUP --make-pidfile --pidfile /var/run/minecraft-backup-index.pid --exec /var/www/nginx-default/backups.rb >> /var/log/minecraft-backup-index.log 2>&1
```
