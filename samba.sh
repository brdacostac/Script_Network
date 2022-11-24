#!/bin/sh
# this script will configure a server for users to be able to use the service Samba

#==========================================
# Title:  Script-Samba
# Author: Bruno DA COSTA CUNHA
# Date:    20/03/2022
#==========================================

configColors(){
    echo "${BLUE}------configColors $@... ${NC}"
    # -> This function will copy the colors.txt file and put it inside the machine by vdn-scp 
    #    and will add the colors variables within bash.rc
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : the client's username

    vdn-scp colors.txt root@$1:colors.txt
    vdn-ssh root@$1 '
        if cat ~/.bashrc|grep "RED=" || cat ~/.bashrc|grep "NC=" || cat ~/.bashrc|grep "GREEN=" || cat ~/.bashrc|grep "BLUE="; then
            echo -e "${GREEN}Colors are already working${NC}"
        else
            cat ~/colors.txt >> ~/.bashrc
        fi
    '
}

# Varibles that will be used to make the code more visible in the screen
BLUE="\\e[1;34m"
RED="\\e[0;33m"
GREEN="\\e[1;32m"
NC="\\033[0m"


installSamba(){
    echo "${BLUE}------installSamba $@... ${NC}"

    # -> Install samba and smbclient packages 
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if apt-get install -y samba && apt-get install -y smbclient;then
            echo -e "${GREEN} DONE ${NC}"
        else
            echo -e "${RED} FAILED ${NC} " >&2
        fi
        sleep 0.5
    '
}

configSAMBA(){
    echo "${BLUE}------configSAMBA $@... ${NC}" 

    # -> This function configure samba service
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : username

    vdn-ssh root@$1 '
        systemctl enable smbd
        echo -e "[partage]
        comment = Partage de données
        path = /srv/partage
        guest ok = no
        read only = no
        browsable = yes
        valid users = '$2'" > /etc/samba/smb.conf
        systemctl restart smbd
        smbpasswd -a '$2' << SAMBAPASSWD
0000
0000
SAMBAPASSWD
       groupadd partage
       gpasswd -a $2 partage
       mkdir -p /srv/partage
       chgrp -R partage /srv/partage/
       chmod -R g+rw /srv/partage/
       sleep 0.5
    '
}

testSAMBA(){
    echo "${BLUE}------testSAMBA $@... ${NC}"

    # -> Tests if samba service works by using smbclient
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : username

    vdn-ssh root@$1 '

        touch ~/partage
        cat << EOF > ~/partage
username = '$2'
password = 0000
domain   = //debian-1/partage
EOF

        if smbclient -c exit -A partage  -U  '$2' //debian-1/partage 0000; then
            echo -e "${GREEN} DONE ${NC}"
        else
            echo -e "${RED} FAILED ${NC}" >&2
            exit 1
        fi
        sleep 0.5
    '
}


# main
 
HOSTNAME=debian-1  # the name of the machine 
NAME=bruno  # the name of the user

installSamba $HOSTNAME
configSAMBA $HOSTNAME $NAME
testSAMBA $HOSTNAME $NAME

echo "${GREEN} END of the script DONE ${NC}"
