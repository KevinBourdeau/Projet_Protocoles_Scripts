
#!/bin/bash

#Déclaration des variables
LOG_CSV=/home/clement/log.csv
LOG=/var/log/apache2/other_vhosts_access.log
HEURE_ACTU=$(date --date '1hours ago' +%H)

#Effacement des lignes du fichier de la dernière heure
rm $LOG_CSV

#Tant qu'il y a des lignes, on récupère l'heure et les adresses IP s'étant connectés sur le site carnofluxe.

while read line
do
        # On récupère seulement les lignes où il y a écrit www.carnofluxe.domain et on récupère les addresse IP
        GREP=$(echo $line | grep "www.carnofluxe.domain" | grep -oP "(25[0-5]|2[0-4]\d|[01]?[0-9]?[0-9]\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])|(\:([0-1][0-9]|[2][0-4])\:([0-5]?[0-9])\:([0-5]?[0-9]))" | sed$
        HEURE=$(echo $GREP | grep -oP ";[0-2][0-9]" | sed "s/;//" )
        CURL=$(echo $line | grep -oP "curl")
        
        #Si les lignes récupérées ont la même heure que la dernière heure et que l'accès au site se fait qu'avec un navigateur alors on récupère l'adresse IP.
        
        if [[ "$HEURE_ACTU" -le "$HEURE" ]] && [[ "$CURL" != "curl" ]]; then
                echo $GREP >> $LOG_CSV #On écrit dans le fichier log.csv
        fi
done < $LOG
