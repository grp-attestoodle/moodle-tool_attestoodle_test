# Moodle de test pour Attestoodle

Ce dépôt contient les ressources nécessaires pour rendre un moodle vierge (par exemple un Moodle virtualisé avec docker), utilisable pour tester Attestoodle.

En clair, ce projet **ne fournit pas un Moodle, mais uniquement des données à mettre dans un Moodle existant**, pour obtenir un contexte de test d'Attestoodle vraisemblable.

Objectif : avoir un moodle qui contient :

* plusieurs espaces cours crédibles
* un grand nombre d'activités de différents types, avec des critères d'achèvements, y-compris avec date d'achèvement attendus
* de nombreux participants à ces espaces
* de nombreuses traces étudiantes, en particulier de nombreux achèvements répartis sur une année
* une formation Attestoodle avec des jalons définis sur ces espaces cours
* un modèle d'attestation

## Remarques préalables

Le présent projet a été initialement conçue et tester avec un moodle virtuel "Caennais".

La plupart des commandes décrites ci-dessous devront être un peu adaptées si le Moodle n'est pas virtuel (pas besoin de `docker compose exec webapp ` avant les commandes) ou si le nom du service serveur web virtualisé n'est pas 'webapp'.

## Usage

Note : la procédure ci-dessous cible un Moodle virtualisé avec docker.  Elle est extrapolable à un Moodle de test déjà existant, en adaptant/supprimant certaines étapes.

1. Instancier un Moodle, par exemple depuis une infrastructure virtuelle comme

* celle du [moodle HQ](https://github.com/moodlehq/moodle-docker) ;
* celle de [Caen](git@git.unicaen.fr:cadiou/moodle-docker.git), si vous y avez accès. 

2. Vérifier la version de Moodle et si besoin la changer. Les données de test ont été faites pour un Moodle en version 2024100702.02, release 4.5.2+ avec la sauvegarde initdb2.sql.

   ```bash
   # depuis le dossier racine de moodle
   cat version.php # doit inclure $release  = '4.5.2+' et $version  = 2024100702.02
   git checkout 5a8b2597522491e9659c39bf225d035290c8dc18
   cd ..
   ```
   Remarque : les sauvegardes initdb0.sql et initdb1.sql restent compatibles avec la version 2022112814.00 (release 4.1.14) de Moodle.

3. Installer les plugins additionnels nécessaires. Pour les installer :

   ```bash
   # depuis le dossier racine de moodle
   git submodule add https://github.com/grp-attestoodle/moodle-tool_attestoodle.git admin/tool/attestoodle
   git submodule add https://github.com/grp-attestoodle/moodle-tool_save_attestoodle.git admin/tool/save_attestoodle
   git submodule add https://github.com/moodlehq/moodle-local_codechecker.git local/codechecker
   ```
   
4. Remplacer le fichier de sauvegarde de BDD qui initialisera la BDD au démarrage (par exemple `inidb.sql` pour l'infra de Caen), par le plus complet fournit dans le présent dépôt ([initdb2.sql](initdb2.sql)) ou si le Moodle n'est pas virtualisé, exécuter le script en question pour restaurer la BD de test et y connecter le Moodle (voir ses paramètres de config.).
      Note : il existe d'autres sauvegardes disponibles si besoin

5. Visiter la plateforme, s'identifier comme admin et accepter la mise à jour de la base de données, ou en CLI :

```bash
docker compose exec webapp php /var/www/html/moodle/admin/cli/upgrade.php
```

6. Visitez [la page d'édition du modèle `tmpl1`](https://localhost/moodle/admin/tool/attestoodle/classes/gabarit/sitecertificate.php?templateid=2) pour y remplacer l'image de fond par [fond1.png](fond1.png) livrée avec ce dépôt.

A ce stade le Moodle contient le plugin Attestoodle et des données qui permettent de l'utiliser pour faire différents tests (non décrits à ce jour).

## Pour refaire les sauvegardes initdbx.sql

Rappel : pour avoir une sauvegarde SQL des différents états décrits ci-après, depuis le serveur de base de données, utiliser à chaque fois :

```bash
docker compose exec dbapp mysqldump -u root -p -q -e -c --single-transaction --add-drop-database --ignore-table=moodle.mdl_logstore_standard_log moodle > <dossier du present projet>/initdbx.sql
```

### initdb0.sql

Moodle sans cours, ni catégorie, ni utilisateurs.

Pour la refaire 

1. supprimer le volume de travail du container du service `dbapp` (ou la BD si le Moodle n'est pas virtualisé)
2. refaire ce qui est décrit dans le chapitre [Usage](#Usage), jusqu'à la visite de la plateforme et sa mise à jour de BD, **mais sans remplacer le script** `initdb.sql`
3. faire la sauvegarde `initdb0.sql`

### initdb1.sql

Idem précédente, mais avec espaces cours et utilisateurs. 

Note : les commandes moosh doivent être exécutées depuis le dossier racine de moodle. Ce qui est le cas par défaut avec l'infra virtuelle de Caen.

1. Augmenter la limite d'upload, en CLI avec
```bash
docker compose exec webapp sed -i "/post_max_size/ s/8/512/" /etc/php/8.0/apache2/php.ini
docker compose exec webapp sed -i "/upload_max_filesize/ s/255/512/" /etc/php/8.0/apache2/php.ini
docker compose exec webapp service apache2 reload
```

2. Créer à la racine une catégorie `categorie_de_test`, ce qui peut se faire en CLI avec 
```bash
docker compose exec webapp moosh -n category-create 'categorie_de_test'
```

3. Copier les mbz de ce présent projet vers le container du service webapp, en CLI avec 
```bash
for f in course-{2..9}.mbz; do 
docker compose cp <dossier du present projet>/$f webapp:/tmp/
done
```
4. Restaurer les `.mbz` fournis, en acceptant toutes les options par défaut, sauf
   * restauration dans la catégorie créée précédemment
   * transformer toutes les inscriptions en inscriptions manuelles
, ce qui peut se faire en CLI avec 
```bash
docker compose exec webapp bash

CATID=$(mysql -h $DB_PORT_3306_TCP_ADDR -u $DB_ENV_MYSQL_USER -p$DB_ENV_MYSQL_PASSWORD --skip-column-names --batch $DB_ENV_MYSQL_DATABASE -e "select id from mdl_course_categories where name = 'categorie_de_test';")

for f in course-{2..9}.mbz; do
echo
echo $f
php admin/cli/restore_backup.php -f=/tmp/$f -c=$CATID -s
done
```
5. faire la sauvegarde `initdb1.sql`

Note : pour repartir d'espaces cours de production plutôt que des mbz fournis, voir la chapitre sur la creation des archives `.mbz`, en annexe.

### initdb2.sql

Idem précédente, mais avec une formation Attestoodle.

(la formation sauvegardée avait l'id 43 (https://ecampus.unicaen.fr/admin/tool/attestoodle/index.php?typepage=trainingmanagement&categoryid=9529&trainingid=43) sur ecampus)

1.  restaurer la formation fournie ( `formation1.json`) avec la fonctionnalité de restauration d'Attestoodle (actuellement issue de son sous-plugin).
2.  faire ce qui est décrit dans le chapitre [Usage](#Usage), pour verser l'image de fond du template `tmpl1` (point 10.)
3. faire la sauvegarde `initdb2.sql`

Note : Si la catégorie `categorie_de_test` n'a pas l'id attendu dans le fichier .json, alors il faudra faire la restauration en acceptant une catégorie au hasard, puis exécuter une requête en base pour changer `categoryid` associé à cette formation. Par exemple si notre catégorie a maintenant l'id 5
```sql
update mdl_tool_attestoodle_training
set categoryid = 5
where name = 'formation_de_test'
```
/!\ ATTENTION ! comme toute intervention directe en base, il se peut que cela ne soit pas suffisant pour avoir un fonctionnement intégralement correct (sujet à creuser)

## Annexes
### Pour supprimer tous les fichiers multimédia des espaces cours 
```bash
docker-compose exec webapp rm -rf /var/moodledata/filedir
```
A priori : inutile !

### Pour crééer les archives .mbz

Pour recréer les archives `.mbz` (au cas ou celles fournies ne seraient plus satisfaisantes), il est possible 

1. de récupérer des sauvegardes de cours intéressantes (du point de vue d'Attestoodle) et de les restaurer 

2. de renommer ces espaces cours pour avoir des noms génériques

3. d'utiliser le script [clean_courses.sql](clean_courses.sql) pour rendre quelconque tous les éléments de contenu (et éviter toutes problématiques de propriété intellectuelle)

4. de sauvegarder tous ces espaces cours avec les options suivantes et seulement elles :

   * Inclure les utilisateurs inscrits
   * Anonymiser les informations des utilisateurs
   * Inclure les attributions de rôles
   * Inclure les activités et ressources
   * Inclure les données détaillées d'achèvement d'activité
   * Inclure l'historique des notes
   * Inclure la banque de questions

   /!\ Ne pas utiliser `moosh course-backup`, il ne conserve pas les rôles, ce qui ruine les achèvements d'activités

Pour savoir comment nommer les sauvegardes s'il faut en écraser une fournie, on peut savoir quelle sauvegarde est associée à quoi avec
```bash
for f in course-{2..9}.mbz; do echo; echo $f; tar -xzf $f --one-top-level=extraction; egrep -i shortname extraction/course/course.xml; rm -rf extraction; done

course-2.mbz
  <shortname>Histoire</shortname>

course-3.mbz
  <shortname>Philosophie</shortname>

course-4.mbz
  <shortname>Economie</shortname>

course-5.mbz
  <shortname>Géographie</shortname>

course-6.mbz
  <shortname>Méthodologie</shortname>

course-7.mbz
  <shortname>Français</shortname>

course-8.mbz
  <shortname>Mathématiques</shortname>

course-9.mbz
  <shortname>Anglais</shortname>

```

### Pour mettre à jour la sauvegarde de la formation

1. exécuter le script [clean_milestones.sql](clean_milestones.sql) pour mettre en cohérence les noms de jalons avec ceux des modules d'activités correspondants.

2. utiliser la fonctionnalité du sous-plugin de sauvegarde d'Attestoodle pour sauver la formation de test sous [formation1.json](formation1.json)

   

