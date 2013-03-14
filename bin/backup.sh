mdb.pl backup --env production

if [ ! -d /media/backup ]
then
    sudo mkdir /media/backup
fi

if [ ! -d /media/backup/ccaroon ]
then
    sudo mount /dev/sdb2 /media/backup
fi

rsync -avz --delete --delete-excluded --exclude-from=/home/ccaroon/bin/backup_excludes.txt /home/ccaroon /media/backup

sudo eject /media/backup
