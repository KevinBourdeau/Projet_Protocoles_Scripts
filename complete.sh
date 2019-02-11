#!/bin/bash
#sauvegarde complete des fichiers /var/www et /apache2
#à executer tous les mois

name_backup=/home/backup/complete/backupcomplete.txt
codeCompleteWWW=/home/backup/complete/completeWWW.txt
codeCompleteAPA=/home/backup/complete/completeAPA.txt
erreur_sauvegarde=/home/clement/erreur_sauvegarde.txt

#recuperer la date (année + mois)
date=$(date +%Y-%m)

#repertoire des sauvegardes completes
complete=/home/backup/complete/$date
mkdir $complete

#sauvegarde des fichiers
cp -r /var/www $complete 2> $erreur_sauvegarde
cp -r /etc/apache2 $complete 2>> $erreur_sauvegarde
echo -e "$date" >> $name_backup

#recuperer code sauvegarde
md5sum $complete/www/*/* | grep -oP ".* " > $codeCompleteWWW
md5sum $complete/www/index.html | grep -oP ".* " >> $codeCompleteWWW
md5sum $complete/apache2/*/* | grep -oP ".* " > $codeCompleteAPA

#gestion du nombre de sauvegarde
ligne=$(wc -l $name_backup | awk '{print $1}')
while [ "$ligne" -eq "7" ]
do
        ligne1=$(head -n 1 $name_backup)
        rm -r /home/backup/complete/$ligne1
        sed -i 1p $name_backup
        ligne=$(wc -l $name_backup | awk '{print $1}')
done

scp -r -p $complete clement@192.168.10.6:/home/clement/sauvegarde

#Si le fichier erreur contient des lignes alors il y a eu des erreurs
if [ -s "$erreur_sauvegarde" ];then
        echo "Echec de la sauvegarde" | mail -s "Problème de sauvegarde" clement 
else
        echo "Sauvegarde réussite"
fi
