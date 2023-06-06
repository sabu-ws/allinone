#!/bin/bash

ACTION=$1
DEVBASE=$2
DEVICE="/dev/${DEVBASE}"
MOUNT_POINT="/mnt/usb"
CHECK_MOUNT_POINT=$(/bin/mount | /bin/grep ${DEVICE} | /usr/bin/awk '{ print $3 }')
DATE=$(date +"[%Y-%m-%d %H:%M:%S]")

# MOUNT KEY
mount_key()
{
    # CHECK IF MOUNT
    if [[ -n ${CHECK_MOUNT_POINT} ]] 
    then
        exit 1
    fi

    # GET INFO DRIVE: $ID_FS_LABEL, $ID_FS_UUID, and $ID_FS_TYPE
    eval $(/sbin/blkid -o udev ${DEVICE})
    LABEL=${ID_FS_LABEL}
    
    if [[ -z "${LABEL}" ]]
    then
        LABEL=${DEVBASE}
    
    elif /bin/grep -q "${MOUNT_POINT}" /etc/mtab 
    then
        LABEL+="-${DEVBASE}"
    fi

    # GLOBAL
    OPTS="rw,relatime"

    # MOUNT
    /bin/mount -o ${OPTS} ${DEVICE} ${MOUNT_POINT}

    # LOG ACTION
    echo "$DATE [USB][Mount] USB key mounted in '/mnt/usb'" >> /sabu/logs/usb.log
}

# UNMOUNT KEY
unmount_key()
{
    if [[ -n ${MOUNT_POINT} ]] 
    then
        # UNMOUNT
        /bin/umount -l ${MOUNT_POINT}

        # LOG ACTION
        echo "$DATE [USB][Mount] USB key unmounted in '/mnt/usb'" >> /sabu/logs/usb.log
    fi
}

# MAIN
echo "$DATE [USB][Detect] USB key detected" >> /sabu/logs/usb.log
case "${ACTION}" in

    add)
        mount_key
        ;;

    remove)
        unmount_key
        ;;
esac
