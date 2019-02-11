#!/bin/bash

#Ce script permet de récupérer les différents status des serveurs HTTP, DNS et leur temps de réponse moyens dans un fichier.
#Ce fichier va alors être envoyer sur le serveur HTTP via une connexion SSH pour qu'il puisse afficher les données sur la page supervision.


#Déclaration de nos variables
FICHIER=status.csv
TEMP=temp.txt

ping -c 5 192.168.10.10 > $TEMP #On ping 5 fois notre serveur HTTP avec le paramètre -c

#On récupère la ligne où est afficher le résultat du ping
echo "paquets transmis;paquets recus;% de paquets perdus;temps(ms)" > $FICHIER
grep "packets" $TEMP | sed 's/[a-z]//g' | sed 's/,/;/g' >> $FICHIER

#Inscription vide pour faire un retour à la ligne
echo "" >> $FICHIER

#On dig pour voir si la résolution de nom fonctionne et on récupère les parties que l'on veut afficher
dig www.carnofluxe.domain > $TEMP

NOERROR=$(grep -oP "status: [A-Z]*" $TEMP | sed 's/status: //') #On récupère la ligne où il y a le mot status
ANSWER=$(grep -oP "^www\..*(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])$" $TEMP) #On récupère la section ANSWER SECTION du dig

#Si la variable NOERROR vaut NOERROR alors la résolution est fonctionnelle sinon  elle n est pas fonctionnelle
if [ "$NOERROR" == "NOERROR" ]; then
        echo "resolution de nom:;fonctionnelle" >> $FICHIER
        echo "status:;$NOERROR" >> $FICHIER
        echo "" >> $FICHIER
        echo "Answer section:" >> $FICHIER
        echo "$ANSWER" >> $FICHIER
else
        echo "resolution de nom non fonctionnelle." >> $FICHIER
fi

#Inscription vide pour faire un retour à la ligne.
echo "" >> $FICHIER

#On vérifie que le site est accessible
#On fait une requete GET via la commande curl sur la page www.carnofluxe.domain
VERIFPAGE=$(curl -I -s "www.carnofluxe.domain" | grep "HTTP/" | grep -oP "[0-9]{3}") #-I permet ne récupérer que le header de la réponse 
                                                                                     #-s permet de ne pas afficher les requetes
TEMPSPAGE=$(curl -I -s -w "Total time: %{time_total}\n" "www.carnofluxe.domain" | grep "Total time:") # On récupère le temps de connexion à la page d'accueil

if [[ "$VERIFPAGE" -ge "200" && "$VERIFPAGE" -le "299" ]]; then
        echo "la page www.carnofluxe.domain est accessible et fonctionnelle.;$TEMPSPAGE ms" >> $FICHIER
else
        echo "la page www.carnofluxe.domain n'est pas accessible." >> $FICHIER
fi

scp -r -p /home/clement/status.csv clement@192.168.10.10:/home/clement #On copie le fichier sur le serveur HTTP pour permettre son affichage

#On regarde le code de sortie de la dernière commande écutée avec $?
EXIT_STATUS=$(echo $?)
echo $EXIT_STATUS

#Si le code exit status vaut 0, alors le fichier est trasnférer s'il est # de 0 alors il y a un problème
if [ "$EXIT_STATUS" -eq "0" ];then

        echo "Transfert du fichier réussi"
else
        echo "Il y a un problème au niveau du transfert du fichier !" | mail -s "Problème de transfert de fichier" clement #Envoie du mail à l'utilisateur clement
fi
