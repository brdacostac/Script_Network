##### Bruno Da Costa Cunha

# SAE 2.03 : NOTICE SAMBA
---

&nbsp;
## Qu'est ce que SAMBA :
&nbsp;

> Le service Samba est un outil permettant de partager des dossiers et des  imprimantes à travers un réseau local.\
> Il permet de partager et d'accéder aux ressources d'autres ordinateurs fonctionnant et puis de le tester !

&nbsp;
## Pré-requis
&nbsp;

> Disposer des droits d'administration.

> Disposer d'une connexion à Internet configurée et activée.


&nbsp;
## Passons à l'installation :
&nbsp;

- D'abord il faut installer le paquet `samba` :

- En mode root tapez : `apt-get -y install samba` et `apt-get -y install smbclient` smbclient est la commande pour pouvoir tester le service samba.

- Ensuite ajoutez un nouveau utilisateur en le créent dans samba, exemple avec l'utilisateur titi : `root@debian-1:~$ smbpasswd -a titi` ***il vous sera demandé d'ajouter un mot de passe***

- Puis créez le groupe partage : `groupadd partage`

- Ensuite ajoutez l'utilisateur titi dans ce groupe avec la comamnde : `gpasswd -a titi partage`

&nbsp;
## Passons à la configuration
&nbsp;

- Tout d'abord pour la copie "Sauvegarde" en cas de problème, il suffit juste d'écrire :
`root@debian-1:~#cp -pf /etc/samba/smb.conf /etc/samba/smb.conf.bak`

- En mode root, dans le fichier `smb.conf`, ajouter les lignes :

    [partage]

    comment = Partage de données

    path = /srv/partage

    guest ok = no

    read only = no

    browseable = yes

    valid users = titi (vous pouvez en ajouter d'autres utilisateurs aussi)


- Ensuite il faut l'héberger à "/srv/partage" : `mkdir /srv/partage`

Pour mettre *partage* comme groupe propriétaire et principal de ce dossier: \
- En tant que root lancez la commande `chgrp -R partage /srv/partage/`
- Puis `chmod -R g+rw /srv/partage/` pour placer les droits de read et write du groupe. 

&nbsp;
## Execution de Samba
&nbsp;

- Pour executer le service samba, on utilise la commande suivante : `smbclient -U toto //debian-1/partage` (***Il vous sera demandé de taper le mot de passe de toto***)