##### Bruno Da Costa Cunha


# SAE 2.03:TP POSTGRE
---


&nbsp;
## Installation
&nbsp;

Pour faire ce tp nous allons tout d'abord devoir installer le service samba.
Intallez le paquet `postgresql` et le paquet `postgresql-client`

- PostGreSQL à chaque modification sur l'état du service nous devons relancer le server `systemctl enable --now postgresql`.

- Par defaut PostGreSQL possède un seul utilisateur, pour s'y connecter : `su - postgres`.

> Créez un nouveau utilisateur dans postGreSQL ( la commande `createuser` peut-être utile)

> Créez une nouvelle base de donnéss dans postGreSQL ( la commande `createdb` peut-être utile)



&nbsp;
## Options utiles
&nbsp;

- Voici des options utiles pour la commande postgre

\h	pour l'aide-mémoire des commandes SQL
\?	pour l'aide-mémoire des commandes psql
\q	pour quitter
\l	liste les bases de données existantes
\d	liste les tables du schéma courant


> Connectez vous dans un utilisateur aillent accés a postGreSQL et testez en créant un fichier .sql