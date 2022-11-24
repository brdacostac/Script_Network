#!/bin/bash
# this script will configure a server for users to be able to use the service postgreSQL

#==========================================
# Title:  Script-Network
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


installationPostGre(){
	echo "${BLUE}------installationPostGre $@... ${NC}"

	# -> This function will install postgrep and postgrepsql-client packages
    #
    # $1 : the machine name, for vdn connection purposes only


	vdn-ssh root@$1 '
		if apt install -y postgresql postgresql-client ; then
			echo -e "${GREEN}DONE${NC}"
		else
			echo -e "${RED}FAILED${NC}" >&2
			exit 1
		fi
		sleep 0.5
	'
}

configPostGre(){
	echo "${BLUE}------configPostGre $@... ${NC}"

	# -> This function will configue the postGre service (/etc/postgresql/12/main/pg_hba.conf)
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : the ip of the machine  
    # $3 : the name of the user that we want him to have database
	
	vdn-ssh root@$1 '
		if systemctl enable --now postgresql; then
			echo 'host    all             all             '$2'            md5' >> /etc/postgresql/12/main/pg_hba.conf
			systemctl restart postgresql

			su - postgres << EOF
psql -c "ALTER USER postgres WITH password '0000'"
createuser '$3'
createdb masuperbdd -O '$3'
EOF
			echo -e "${GREEN}DONE${NC}"
		else
			echo -e "${RED}FAILED${NC}" >&2
			exit 1
		fi
		sleep 0.5
	'
}

testPostgre(){
	echo "${BLUE}------testPostgre $@... ${NC}"

	# -> This function will test postGre service by using the command `psql -l`
    #
    # $1 : the machine name, for vdn connection purposes only
    # $2 : the username  
 

	vdn-ssh $2@$1 '
		if psql -l ; then
			echo -e "${GREEN}DONE${NC}" 
		else
			echo -e "${RED}FAILED${NC}" >&2
			exit 1			
		fi
		sleep 0.5
	'
}


# main
 
HOSTNAME=debian-1   # the name of the machine 
RESEAUXLOCAL=10.0.2.15   # the ip of the machine  
USER=test # the name of the user that we want him to have database

installationPostGre $HOSTNAME
configPostGre $HOSTNAME $RESEAUXLOCAL $USER
testPostgre $HOSTNAME $USER

echo "${GREEN} END of the script DONE ${NC}"
