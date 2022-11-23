#!/bin/sh


# Varibles that will be used to make the code more visible in the screen
BLUE="\\e[1;34m"
RED="\\e[0;33m"
GREEN="\\e[1;32m"
NC="\\033[0m"


baseConfig(){
    echo "${BLUE}------baseConfig $@... ${NC}"

    # Sets the machine name (/etc/hostname) and 
    # adds IP match <-> name (/etc/hosts)
    # 
    # $1 : machine name
    # $2 : IP of the machine
    
    vdn-ssh root@$1 '
        # fixe le nom de la machine (/etc/hostname)
        echo '$1' > /etc/hostname
        hostname -F /etc/hostname
 
        # update the machine
        apt-get update -y

        # sets match IP <-> nom (/etc/hosts)
        if ! grep -q '$2' /etc/hosts; then
            echo '$2 $1' >> /etc/hosts
        fi
        '
}
 
testBaseConfig(){
    echo "${BLUE}------testBaseConfig $@... ${NC}"

    # TestBaseConfig
    # 
    # $1 : machine name
    # $2 : IP of the machine

    vdn-ssh test@$1 '
        if [ $(hostname) != "debian-1" ]; then
            echo "${RED} ERROR: Nom hôte invalide !" >&2
            exit 1
        fi
 
        if ! ping -c 1 '$1' &> /dev/null; then
            echo "${RED} ERROR: Impossible de joindre '$1' !" >&2
            exit 1
        fi
    '
}
 
apache2() {
    echo "${BLUE}------apache2 $@... ${NC}\n"

    vdn-ssh root@$1 '
        apt-get install -y apache2 lynx
 
        cat << EOF > /var/www/html/index.html
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<center><h1>Bienvenue sur le serveur Web de '$1'</h1></center>
</body>
</html>
EOF
        #Enable userdir service to use http protected
        a2enmod userdir
        systemctl restart apache2
    '
}
 
testApache2() {
    echo "${BLUE}------testApache2 $@... ${NC}\n"
    vdn-ssh test@$1 '
        if ! lynx -dump http://localhost | grep -q Bienvenue; then
            echo "${RED} ERROR: page index.html invalide !" >&2
            exit 1
        fi
    '
}


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


addUser() {
    echo "${BLUE}------addUser $@... ${NC}"

    # -> This function will add a new user in an iteretive and no password like manner
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : the client's username
    
    vdn-ssh root@$1 '
        if adduser '$2' --disabled-password --gecos GECOS; then
            echo -e "${GREEN} SUCCESS: New user created ${NC}"
            passwd -d '$2'
            exit 0
        fi
        exit 1

        sleep 0.5
    '
}

testAddUser() {
    echo "${BLUE}------testAddUser $@... ${NC}"

    # -> This function will test if a new user has been created
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : the client's username

    vdn-ssh root@$1 '
        if [ ! -e /home/'$2' ];then
            echo -e "${RED} ERROR: failed to create new user ! ${NC}" >&2
            exit 1
        fi
        exit 0

        sleep 0.5
    '
}


instalNFS(){
    echo "${BLUE}------installNFS $@... ${NC}"

    # -> This function will installs the nfs server on the machine
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if apt install -y nfs-kernel-server; then
            echo -e "${GREEN} DONE ${NC}"
        fi
        
        sleep 0.5
    '
}

testInstalNFS(){
    echo "${BLUE}------testInstalNFS $@... ${NC}"

    # -> This function will check if the nfs server is working
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if systemctl enable --now nfs-server.service;then
            echo -e "${GREEN} SUCCESS: NFS installation done ${NC}"
            exit 0
        else
            echo -e "${RED} ERROR: NFS installation failed ${NC}" >&2
            exit 1
        fi
        sleep 0.5
    '
}


configNFS(){
    echo "${BLUE}------configNFS $@... ${NC}"

    # -> This function will configure the NFS server (/etc/exports) if it insn't already configured
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : the name rights of the client on the folder
    # $3 : the path of the server folder that we want to share
    # $4 : the path of the client folder
    # $5 : the name of the client machine
    # $6 : the name of the server machine


    vdn-ssh root@$1 '
        toto="'$3 $5'('$2',sync,fsid=1,no_subtree_check)"
        mkdir -p "$3"
        mkdir -p "$4"
        if /etc/init.d/nfs-kernel-server restart ;then
            if grep "$toto" < /etc/exports; then
                echo -e "${GREEN} SUCCESS: Configuration NFS done ${NC}"
            else
                echo -e "${GREEN} Editing the file /etc/exports ${NC}"
                echo "$toto" >> /etc/exports
                echo -e "${GREEN} SUCCESS: Configuration NFS done ${NC}"
            fi
            /etc/init.d/nfs-kernel-server reload
            exit 0
        else 
            echo -e "${RED} ERROR: Configuration NFS failed ${NC}"
            exit 1
        fi

        sleep 0.5
    '
}

testNFS() {
    echo "${BLUE}------testNFS $@... ${NC}"

    # -> This function will test if NFS server is configured (/etc/exports)
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : the name rights of the client on the folder
    # $3 : the path of the server folder that we want to share
    # $4 : the path of the client folder
    # $5 : the name of the client machine
    # $6 : the name of the server machine

    vdn-ssh root@$1 '
        if mount -t nfs '$6:$3 $4' -o '$2' ;then
            echo -e "${GREEN} SUCCESS: testNFS done ${NC}"
        else
            echo -e "${RED} ERROR: testNFS failed ${NC} " >&2
            exit 1
        fi
        sleep 0.5
    '
}

installationSSH() {
    echo "${BLUE}------installationSSH $@... ${NC}"

    # -> This function will install ssh and configure the computer to connect ssh (~/.ssh/authorized_keys)
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        apt install ssh -y
        chmod 700 /root/.ssh/*
        if echo -e "\n" | ssh-keygen -N "" &> /dev/null; then
            echo -e "${GREEN} SUCCESS: SSH key pair created done ${NC}"
        else
            echo -e "${RED} ERROR: SSH key pair not created failed ${NC}" >&2
        fi

        if grep '$1' < /root/.ssh/authorized_keys; then
            echo -e "${GREEN} SSH key pair are already in authorized_keys ${NC}"
        else
            echo $(cat /root/.ssh/id_rsa.pub) >> /root/.ssh/authorized_keys
        fi
        sleep 0.5
    '
}

testSCP() {
    echo "${BLUE}------testSCP $@... ${NC}"

    # -> This function will test whether the scp command works interactively
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        echo "teste" > /media/testScp.txt
        if scp -o  StrictHostKeyChecking=no -r root@localhost:/media/testScp.txt root@localhost:/media/testScp2.txt; then
            echo -e "${GREEN} SUCCESS: testSCP done ${NC}"
        else
            echo -e "${RED} ERROR: testSCP failed ${NC}" >&2
            exit 1
        fi
        sleep 0.5
    '
}


sshfsInstall(){
    echo "${BLUE}------sshfsInstall $@... ${NC}"

    # -> This function will install sshfs
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if apt-get install sshfs -y; then
            echo -e "${GREEN} DONE ${NC}"
        else 
            echo -e "${RED} FAILED ${NC}" >&2
        fi
        touch testeSSHFS
        sleep 0.5
    '
}

testSSHFS(){
    echo "${BLUE}------testSSHFS $@... ${NC}"

    # -> This function will test whether the sshfs command works 
    # (to work iteratively, you need to launch the installSSH function first)
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        mkdir /media/homeRootSSHFS
        if sshfs -o  StrictHostKeyChecking=no root@'$1': /media/homeRootSSHFS; then
            echo -e "${GREEN} SUCCESS: SSHFS done ${NC}"
            fusermount -u /media/homeRootSSHFS
        else
            echo -e "${RED} ERROR: SSHFS failed ${NC} " >&2
        fi

        sleep 0.5
    '
}


ftpInstall(){
    echo "${BLUE}------ftpInstall $@... ${NC}"

    # -> Install ftp and proftpd packages
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if apt install -y ftp && apt install -y proftpd; then
            echo -e "${GREEN} DONE ${NC}"
        else
            echo -e "${RED} FAILED ${NC} " >&2
            exit 1
        fi
    
        sleep 0.5
    '

}


ftpTest(){
    echo "${BLUE}------ftpTest $@... ${NC}"

    # -> This function will test ftp works by restarting proftpd
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if /etc/init.d/proftpd restart; then
            echo -e "${GREEN} SUCCESS: FTP configurated done ${NC}"
        else
            echo -e "${RED} ERROR: FTP not configurated failed ${NC}" >&2
        fi

        sleep 0.5
    '
}


httpProtege(){
    echo "${BLUE}------httpProtege $@... ${NC}"

    # -> This function will configure a page html protected
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh test@$1 '

        mkdir -p ~/public_html/secret 2> /dev/null
        cat << EOF > ~/public_html/secret/.htaccess
AuthType Basic
AuthUserFile /etc/apache/users
AuthName "Accès privé"
require user teste
EOF
        mkdir ~/public_html/
        touch ~/public_html/index.html
        cat << EOF > ~/public_html/secret/index.htm
<html><body><h1>HTTP PROTEGE</h1></body></html>
EOF
        sleep 0.5
    '
}

testHttpProtege(){
    echo "${BLUE}------testHttpProtege $@... ${NC}"

    # -> This function will test whether the index file.html is protected 
    # (you need to have released the apache2 function first)
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if ! lynx -dump http://debian-1/~test/secret/index.html; then
            echo -e "${GREEN} SUCCESS: HttpPROTEGE done ${NC}"
        else
            echo -e "${RED} ERROR: HttpPROTEGE failed ${NC}" >&2
            exit 1
        fi

        sleep 0.5
    '
}


clientServerRb(){

    echo "${BLUE}------ClientServerRb $@... ${NC}"

    # -> Install ruby package and takes the "client.rb" and the "server.rb" files that will be placed in the machine 
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if apt install -y ruby; then
            echo -e "${GREEN} DONE ${NC}"
        else
            echo -e "${RED} FAILED ${NC}" >&2
            exit 1
        fi
    '
    echo "-Creation ruby's CLIENT-"
    vdn-scp client.rb root@$1:/usr/local/bin/client.rb

    echo "-Creation ruby's SERVER-"
    vdn-scp server.rb root@$1:/usr/local/bin/server.rb
    sleep 0.5
}


testRubyRb(){
    echo "${BLUE}------TestRubyRb $@... ${NC}"

    # -> Check if server.rb and client.rb files are in the machine 
    #
    # $1 : the machine name, for vdn connection purposes only

    vdn-ssh root@$1 '
        if [ -e /usr/local/bin/server.rb ] && [ -e /usr/local/bin/client.rb ];then
            echo -e "${GREEN} SUCCESS: Ruby is configurated done ${NC}"
        else
            echo -e "${RED} ERROR: Ruby is not configurated failed ${NC}" >&2
            exit 1
        fi

        sleep 0.5
    '
}



# main
 
HOSTNAME=debian-1   # the name of the machine 
IP=10.0.2.15   # the ip of the machine
NAME=bruno  # the username

#ConfigNFS
    
RIGHTS=ro   # the name rights of the client on the folder
PATHFROM=/overlays/ro/usr/share/doc    # the path of the server folder that we want to share
PATHTO=/mnt/doc     # the path of the client folder
CLIENTMACHINE=$HOSTNAME  # the name client machine
SERVERMACHINE=$HOSTNAME   # the name server machine

#===========Colors configuration===========
configColors $HOSTNAME

#===========Base Configuration===========
baseConfig $HOSTNAME $IP
testBaseConfig $HOSTNAME

#===========Apache2=========== 
apache2 $HOSTNAME
testApache2 $HOSTNAME

#===========addUser===========
addUser $HOSTNAME $NAME
testAddUser $HOSTNAME $NAME


#===========addUser===========
instalNFS $HOSTNAME
testInstalNFS $HOSTNAME


#===========NFS===========
configNFS $HOSTNAME $RIGHTS $PATHFROM $PATHTO $CLIENTMACHINE $SERVERMACHINE
testNFS $HOSTNAME $RIGHTS $PATHFROM $PATHTO $CLIENTMACHINE $SERVERMACHINE


#===========SSH and SCP===========
installationSSH $HOSTNAME
testSCP $HOSTNAME

#===========SSHFS===========
sshfsInstall $HOSTNAME
testSSHFS $HOSTNAME

#===========FTP===========
ftpInstall $HOSTNAME
ftpTest $HOSTNAME

#===========HTTP===========
httpProtege $HOSTNAME
testHttpProtege $HOSTNAME

#===========Ruby===========
clientServerRb $HOSTNAME
testRubyRb $HOSTNAME


echo "${GREEN} END of the script DONE ${NC}"