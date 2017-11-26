# How to:
**Bootstrapping a RaspberryPi 3**
1. Install the CentOS minimal image: http://mirror.centos.org/altarch/7/isos/armhfp/CentOS-Userland-7-armv7hl-Minimal-1603-RaspberryPi3.img.xz

2. Flash your SD card using Etcher: https://etcher.io

3. Expand the root file system after booting into CentOS:
```
# expand root fs instructions taken from:
# https://github.com/rharmonson/richtech/wiki/Using-CentOS-7.2.1511-Minimal-on-the-Raspberry-PI-3#manual-expand-rootfs

[root@centos-rpi3 ~]# fdisk -l

[root@centos-rpi3 ~]# fdisk /dev/mmcblk0

Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p

Disk /dev/mmcblk0: 63.9 GB, 63864569856 bytes, 124735488 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000a4da3

        Device Boot      Start         End      Blocks   Id  System
/dev/mmcblk0p1            2048      616447      307200    c  W95 FAT32 (LBA)
/dev/mmcblk0p2          616448     1665023      524288   82  Linux swap / Solaris
/dev/mmcblk0p3         1665024     5859327     2097152   83  Linux

Command (m for help): d
Partition number (1-3, default 3): 3
Partition 3 is deleted

Command (m for help): n
Partition type:
   p   primary (2 primary, 0 extended, 2 free)
   e   extended
Select (default p): p
Partition number (3,4, default 3):
First sector (1665024-124735487, default 1665024):
Using default value 1665024
Last sector, +sectors or +size{K,M,G} (1665024-124735487, default 124735487):
Using default value 124735487
Partition 3 of type Linux and of size 58.7 GiB is set

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.

[root@centos-rpi3 ~]# reboot
```

4. Install the RaspberryPi3 bootstrap script
```
yum -y install wget
wget https://raw.githubusercontent.com/cmdallas/mining-scripts/master/bootstrap/bootstrap_pi3_centos.sh
chmod 755 bootstrap_pi3_centos.sh
```

5. Run the bootstrap script
```
./bootstrap_pi3_centos.sh monitoring1 10.0.0.100 255.255.255.0 10.0.0.1 [optional: aws_access_key_id aws_secret_access_key]
```
