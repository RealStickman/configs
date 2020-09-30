# Restic repos:

## B2 backups

export B2_ACCOUNT_ID=  
export B2_ACCOUNT_KEY=  

### arco-pc-backup home:
restic -r b2:arco-pc-backup:/home/marc init
restic -r b2:arco-pc-backup:/home/marc backup --verbose "/home/marc/" --exclude-file=/home/marc/Dokumente/home-exclude.txt
restic -r b2:arco-pc-backup:/home/marc snapshots
restic -r b2:arco-pc-backup:/home/marc restore --target "/home/marc/" <snapshot>

#arco-pc-backup timeshift:
restic -r b2:arco-pc-backup:/mnt/harddrive/timeshift/snapshots init
#sudo chmod -Rv 777 /mnt/1d90c4d5-21d2-4455-bb4a-814de8496744/timeshift/
sudo -E restic -r b2:arco-pc-backup:/mnt/harddrive/timeshift/snapshots backup --verbose "/mnt/1d90c4d5-21d2-4455-bb4a-814de8496744/timeshift/snapshots/"
restic -r b2:arco-pc-backup:/mnt/harddrive/timeshift/snapshots snapshots
restic -r b2:arco-pc-backup:/mnt/harddrive/timeshift/snapshots restore --target "/mnt/1d90c4d5-21d2-4455-bb4a-814de8496744/timeshift/snapshots/" <snapshot>

#arco-pc-backup consoles:
restic -r b2:arco-pc-backup:/mnt/harddrive/Consoles init
restic -r b2:arco-pc-backup:/mnt/harddrive/Consoles backup --verbose "/mnt/1d90c4d5-21d2-4455-bb4a-814de8496744/Consoles"
restic -r b2:arco-pc-backup:/mnt/harddrive/Consoles snapshots
restic -r b2:arco-pc-backup:/mnt/harddrive/Consoles restore --target "/mnt/1d90c4d5-21d2-4455-bb4a-814de8496744/Consoles" <snapshot>

#rpi3-backup
restic -r b2:rpi3-backup:timeshift/snapshots init
sudo chmod -Rv 777 /run/timeshift/backup/timeshift
restic -r b2:rpi3-backup:timeshift/snapshots backup --verbose "/run/timeshift/backup/timeshift/snapshots"
restic -r b2:rpi3-backup:timeshift/snapshots snapshots
restic -r b2:rpi3-backup:timeshift/snapshots restore --target "/run/timeshift/backup/timeshift/snapshots" <snapshot>

#realstickman-xyz-backup root
restic -r b2:realstickman-xyz-backup:root init
restic -r b2:realstickman-xyz-backup:root backup --verbose "/root"
restic -r b2:realstickman-xyz-backup:root snapshots 
restic -r b2:realstickman-xyz-backup:root restore --target "/root" <snapshot>

#realstickman-xyz-backup etc
restic -r b2:realstickman-xyz-backup:etc init
restic -r b2:realstickman-xyz-backup:etc backup --verbose "/etc"
restic -r b2:realstickman-xyz-backup:etc snapshots 
restic -r b2:realstickman-xyz-backup:etc restore --target "/etc" <snapshot>
