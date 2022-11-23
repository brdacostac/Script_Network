##### Bruno Da Costa Cunha

# SAE 2.03:NOTICE POSTGRE
---

&nbsp;
## Qu'est ce que PostGRE :
&nbsp;

PostGre est un service réseaux-client, capable de prendre en charge de données les plus complexes. Nous allons parler donc de SQL, dans laquelle on pourra créer notre propre espace de bases de données.


&nbsp;
## Pré-requis
&nbsp;

> Disposer des droits d'administration.

&nbsp;
### Installation et activation
&nbsp;

- En première étape, installer les paquets postgresql et postgresql-client : `apt install postgresql postgresql-client`

- Ensuite l'activer avec l'utilisation de la commande `systemctl enable --now postgresql`

&nbsp;
## Fonctionnement
&nbsp;

Un utilisateur doit seulement taper `psql` suivi de son compte, puis rentrer son mot de passe, pour qu'il accède à PostGreSQL. Dedans il peut rentrer n'importe quel commande correspondant au sql, comme par exemple :`CREATE TABLE`*Créer une table*, `Select `*Afficher* ... pour quiter le service Psql : `\q`.

&nbsp;
## Configuration
&nbsp;

- Tout d'abord il faut se connecter sur postgres avec l'aide de la commande  `su - postgres`.

- Ensuite on change le mot de passe pour la securité :`psql -c "ALTER USER postgres WITH password "MOT_DE_PASSE"`.

- Puis comme par defaut juste postgres a les droits d'utiliser ce service, nous pouvons créer un nouveau utilisateur avec la l'aide de la commande `createuser "utilisateur"`. 
- Enfin on crée la base de données de ce nouveau utilisateur `createdb debian-1 -O "utilisateur"`.

&nbsp;
## Options Utiles
&nbsp;

- Voici des options utiles pour la commande postgre

\h	pour l'aide-mémoire des commandes SQL
\?	pour l'aide-mémoire des commandes psql
\q	pour quitter
\l	liste les bases de données existantes
\d	liste les tables du schéma courant

&nbsp;
## Utilisation
&nbsp;

**Exemple d'utilisation dans postgre**
SELECT t.table_name
FROM table t
ORDER BY t.table_name;