
#!/bin/bash

#Création des variables
LOG_CSV=/home/clement/log.csv
STATUS_CSV=/home/clement/status.csv
ERREURS_STATUS=/home/clement/erreurs_status.log
ERREURS_LOG=/home/clement/erreurs_log.log

#Création des pages html
LOG_HTML=/var/www/supervision/log.html
STATUS_HTML=/var/www/supervision/status.html

RECUP_LOG=$(grep -oP "\/.*" $ERREURS_LOG) #On garde que la ligne d'erreur
RECUP_STATUS=$(grep -oP "\/.*" $ERREURS_STATUS)

#Si le fichier log.csv existe on convertit le csv
if [ -f "$LOG_CSV" ]; then
        echo "<B>Ceci sont les IP's connectees sur le site Carnofluxe.domain durant la derniere heure </B><br>" > $LOG_HTML
        echo "<table border="2">" >> $LOG_HTML
        echo "<tr> <th> Adresses IP </th><th> Heure </th></tr>" >> $LOG_HTML
        while read line
        do
                echo $line | awk -F ";" '{printf "<tr>" "<td>"$1"</td>" "<td>"$2"</td>" "</tr>"}' >> $LOG_HTML
                #echo $line
        done < $LOG_CSV
        echo "</table>" >> $LOG_HTML
else
        echo "Fichier log.csv introuvable." # S'il n'existe pas où il y a un problème on affiche les erreurs sur la page
        $LOG_CSV 2> $ERREURS_LOG
        echo $RECUP_LOG > $LOG_HTML #On rediriges les erreurs du fihcier sur la page html
fi

if [ -f "$STATUS_CSV" ]; then
        echo "Ceci est le status du site Carnofluxe <br>" > $STATUS_HTML
        while read line
        do
                echo "$line <br>" >> $STATUS_HTML
        done < $STATUS_CSV
else
        echo "Fichier status.csv introuvable."
        $STATUS_CSV 2> $ERREURS_STATUS
        echo $RECUP_STATUS > $STATUS_HTML #On redirige les erreurs du fihcier sur la page html
fi
