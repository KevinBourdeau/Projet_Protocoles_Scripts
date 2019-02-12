
#!/bin/bash
# script permettant de sauvegarder les fichiers importants du serveur HTT$

CodeCompleteWWW=/home/backup/complete/completeWWW.txt
CodeCompleteAPA=/home/backup/complete/completeAPA.txt
CodeNouvelleWWW=/home/backup/complete/nouvelleWWW.txt
CodeNouvelleAPA=/home/backup/complete/nouvelleAPA.txt
diff=/home/backup/complete/diff.txt
erreur_sauvegardeDiff=/home/clement/erreur_sauvegardeDiff.txt

#recuperer la date du jour et la date de la veille
date=$(date +%Y-%m-%d)
datemois=$(date +'%Y-%m')

#recupere les codes des fichier var/www et /etc/apache2
md5sum /var/www/*/* | grep -oP ".* " > $CodeNouvelleWWW
md5sum /var/www/index.html | grep -oP ".* " >> $CodeNouvelleWWW
md5sum /etc/apache2/*/* | grep -oP ".* " > $CodeNouvelleAPA

#repertoire de sauvegardes
backup=/home/backup/complete/$datemois/$date
mkdir $backup

#comparaison des codes /var/www avec ceux de la sauvegarde complete
diff $CodeCompleteWWW $CodeNouvelleWWW > $diff
if [ -s $diff ]; then
        mkdir $backup/www
        cp -r /var/www $backup/www 2> $erreur_sauvegardeDiff
        echo "sauvegarde de /var/www"
else
        sauv=false
fi

#comparaison des codes /etc/apache2 avec ceux de la sauvegarde complete
diff $CodeCompleteAPA $CodeNouvelleAPA > $diff
if [ -s $diff ]; then
        mkdir $backup/apache2
        cp -r /etc/apache2 $backup/apache2 2>> $erreur_sauvegardeDiff
        echo "sauvegarde de /etc/apache"
else
        sauv1=false
fi

#si aucune sauvegarde
if [[ "$sauv" == false && "$sauv1" = false ]]; then
        echo "aucun changement depuis la précédente sauvegarde"
        rm -r $backup
fi

scp -r -p $backup clement@192.168.10.6:/home/clement/sauvegarde #Copie de la sauvegarde sur le serveur dnSlave.

#Si le fichier erreur contient des lignes alors il y a eu des erreurs
if [ -s "$erreur_sauvegardeDiff" ];then # -s vérifie si le fichier est plein
        echo "Echec de la sauvegarde" | mail -s "Problème de sauvegarde" clement 
else
        echo "Sauvegarde réussite"
fi 
