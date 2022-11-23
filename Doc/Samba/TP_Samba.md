##### Bruno Da Costa Cunha

# SAE 2.03 : TP Samba
---

&nbsp;
## Installation
&nbsp;

Pour faire ce tp nous allons tout d'abord devoir installer le service samba.
Intallez le paquet `samba` et le paquet `smbclient`

- La commande `chown user:user Répertoire ` permet d'attribuer les droits utilisateur groupe sur le dossier !

> Donnez une autre commande permettant de changer les droits d'utilisateur groupe sur un dossier.

&nbsp;
## Configuration
&nbsp;

- Maintenant passons à sa configuration, on a les options suivantes :

-a -> permet d'ajouter un utilisateur à la base de données

-x -> permet de d'expulser un utilisateur de l'acces à la base de données

-d -> permet de désactiver un utilisateur de l'acces à la base de données 

-e -> permet d'activer ou de réactiver un utilisateur l'acces a la base de données 

> En utilisant la commande `smbpasswd`  ajoutez un utilisateur  dans la base de données de Samba.
>
> Que ce passe t'il si on ne précise pas de mot de passe lors de l'utilisation de la commande précédente ?

- Pour ajouter les accès au dossier de partage, il faut rajouter les lignes de commande :

    ` [Nom_Répertoire] ` 

    `comment = Partage de données`

    `path = chemin` 

    `guest ok = no`

    `read only = no`

    `browseable = yes`

    `valid users = User` 

    

    *Pour que les modifications soient prises*:  `systemctl restart smbd` 

- Pour le groupe de partage :

> Créez un groupe appelé "partage" (rappel la commande groupadd permet de créer des groupes)
>
> Ajoutez un utilisateur dans le nouveau groupe partage

- Pour finir la configuration : 

  > Créez un dossier partage dans "/srv/partage"
  >
  > Donnez le titre de propriétaire au dossier partage a l'aide de la commande `chgrp` et de l'option -R
  >
  > Placez les droits de lecture et ecriture sur groupe (g)

&nbsp;

## Execution /  Test

&nbsp;

> Ajoutez un fichier dans le "partage" et connectez vous sur un ulisateur pour verifier que ce fichier existe