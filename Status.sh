#!/bin/bash

#Ce script permet de r�cup�rer les diff�rents status des serveurs HTTP, DNS et leur temps de r�ponse moyens dans un fichier.
#Ce fichier va alors �tre envoyer sur le serveur HTTP via une connexion SSH pour qu'il puisse afficher les donn�es sur la page supervision.


#D�claration de nos variables
FICHIER=status.csv
TEMP=temp.txt

ping -c 5 192.168.10.10 > $TEMP #On ping 5 fois notre serveur HTTP avec le param�tre -c

#On r�cup�re la ligne o� est afficher le r�sultat du ping
echo "paquets transmis;paquets recus;% de paquets perdus;temps(ms)" > $FICHIER
grep "packets" $TEMP | sed 's/[a-z]//g' | sed 's/,/;/g' >> $FICHIER

#Inscription vide pour faire un retour � la ligne
echo "" >> $FICHIER

#On dig pour voir si la r�solution de nom fonctionne et on r�cup�re les parties que l'on veut afficher
dig www.carnofluxe.domain > $TEMP

NOERROR=$(grep -oP "status: [A-Z]*" $TEMP | sed 's/status: //') #On r�cup�re la ligne o� il y a le mot status
ANSWER=$(grep -oP "^www\..*(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])$" $TEMP) #On r�cup�re la section ANSWER SECTION du dig

#Si la variable NOERROR vaut NOERROR alors la r�solution est fonctionnelle sinon  elle n est pas fonctionnelle
if [ "$NOERROR" == "NOERROR" ]; then
        echo "resolution de nom:;fonctionnelle" >> $FICHIER
        echo "status:;$NOERROR" >> $FICHIER
        echo "" >> $FICHIER
        echo "Answer section:" >> $FICHIER
        echo "$ANSWER" >> $FICHIER
else
        echo "resolution de nom non fonctionnelle." >> $FICHIER
fi

#Inscription vide pour faire un retour � la ligne.
echo "" >> $FICHIER

#On v�rifie que le site est accessible
#On fait une requete GET via la commande curl sur la page www.carnofluxe.domain
VERIFPAGE=$(curl -I -s "www.carnofluxe.domain" | grep "HTTP/" | grep -oP "[0-9]{3}") #-I permet ne r�cup�rer que le header de la r�ponse 
                                                                                     #-s permet de ne pas afficher les requetes
TEMPSPAGE=$(curl -I -s -w "Total time: %{time_total}\n" "www.carnofluxe.domain" | grep "Total time:") # On r�cup�re le temps de connexion � la page d'accueil

if [[ "$VERIFPAGE" -ge "200" && "$VERIFPAGE" -le "299" ]]; then
        echo "la page www.carnofluxe.domain est accessible et fonctionnelle.;$TEMPSPAGE ms" >> $FICHIER
else
        echo "la page www.carnofluxe.domain n'est pas accessible." >> $FICHIER
fi

scp -r -p /home/clement/status.csv clement@192.168.10.10:/home/clement #On copie le fichier sur le serveur HTTP pour permettre son affichage

#On regarde le code de sortie de la derni�re commande �cut�e avec $?
EXIT_STATUS=$(echo $?)
echo $EXIT_STATUS

#Si le code exit status vaut 0, alors le fichier est trasnf�rer s'il est # de 0 alors il y a un probl�me
if [ "$EXIT_STATUS" -eq "0" ];then

        echo "Transfert du fichier r�ussi"
else
        echo "Il y a un probl�me au niveau du transfert du fichier !" | mail -s "Probl�me de transfert de fichier" clement #Envoie du mail � l'utilisateur clement
fi
