#/bin/bash

display_usage(){
    clear
    echo "============================================================"
    echo "This Kraken utility is used to start and stop services"
    echo "required to run Kraken, as well as update Kraken with the"
    echo "latest version."
    echo ""
    echo "Usage: $0 [start|stop|restart|update]"
    echo "============================================================"
}

if [ $# -le 0 ]
    then
        display_usage
        exit 0
fi

start(){
    sudo /etc/init.d/rabbitmq-server start
    sudo /etc/init.d/celeryd start
    sudo /etc/init.d/apache2 start
    echo ""
    printf "\033[1;31mKraken started.\033[0m\n"
    port=$(awk 'c&&!--c{print $2};/\#Kraken\ Entry/{c=1}' /etc/apache2/ports.conf)
    printf "\033[1;31mOpen a browser and navigate to http://localhost:$port\033[0m\n"
    echo ""
}

stop(){
    sudo /etc/init.d/rabbitmq-server stop
    sudo /etc/init.d/celeryd stop
    sudo /etc/init.d/apache2 stop
    printf "\033[1;31mKraken stopped.\033[0m\n"
}

update(){
    printf "\033[1;31mWARNING! This will delete your Kraken database!\033[0m\n"
    read -p "Press [enter] to continue or Ctrl+c to cancel."
    printf "\033[1;31mStopping Kraken\033[0m\n"
    stop
    rm -rf /tmp/Kraken
    printf "\033[1;31mDownloading latest version of Kraken\033[0m\n"
    git clone https://github.com/Sw4mpf0x/Kraken.git /tmp/Kraken
    rm -rf /opt/Kraken
    mv /tmp/Kraken/Kraken /opt/
    secretkey=$(echo 'import random;print "".join([random.SystemRandom().choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)])' | python)
    echo SECRET_KEY = \'$secretkey\' >> /opt/Kraken/Kraken/settings.py
    /opt/Kraken/manage.py makemigrations
    /opt/Kraken/manage.py migrate
    chown -R www-data /opt/Kraken
    chgrp -R www-data /opt/Kraken
    chmod 775 /opt/Kraken/Kraken/
    chmod 775 /opt/Kraken/Kraken/kraken.db
    chmod 775 /opt/Kraken/Web_Scout/static/Web_Scout/
    chmod 775 /opt/Kraken/ghostdriver.log
    chmod 775 /opt/Kraken/tmp/
    echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@kraken.com', '2wsxXSW@')" | python /opt/Kraken/manage.py shell
    printf "\033[1;31mStarting Kraken\033[0m\n"
    chmod 755 /tmp/Kraken/update.sh
    if [ -a "/tmp/Kraken/update.sh" ]
        then
            chmod 755 /tmp/Kraken/update.sh
            /tmp/Kraken/update.sh
    fi
    start
    rm -rf /tmp/Kraken
    printf "\033[1;31mUpdate complete!\033[0m\n"
}

backup(){
    zip -j KrakenBackup.zip /opt/Kraken/Kraken/kraken.db /opt/Kraken/Web_Scout/static/Web_Scout/*
    printf "\033[1;31mBackup saved to KrakenBackup.zip in current working directory.\033[0m\n"
}

restore(){
    while [ -z "$backuppath" ]
    do
        echo "Specify absolute path to KrakenBackup.zip: "
        read backuppath
    done

    if [ ! -d "/tmp/krakenbackup" ]
        then
            mkdir /tmp/krakenbackup
    fi
    unzip $backuppath -d /tmp/krakenbackup/
    cp /tmp/krakenbackup/kraken.db /opt/Kraken/Kraken/kraken.db
    cp /tmp/krakenbackup/*.png /opt/Kraken/Web_Scout/static/Web_Scout/
    rm -rf /tmp/krakenbackup
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reset|restart)
        printf "\033[1;31mResetting Kraken.\033[0m\n"
        stop
        start
        ;;
    update)
        update
        ;;
    backup)
        backup
        ;;
    restore)
        restore
        ;;
    *)
        display_usage
        exit 1
esac

exit 0