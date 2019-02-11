
# Projet_Protocoles_Scripts
Le but est de  fournir une solution pour aider la société Carnofluxe à adapter son système d’information pour accueillir à terme un site de e-commerce et mettre en place des outils de supervision de ce site.


# Installation et configuration

Nous avons créé 3 serveurs :


| Nom | Type serveur | Paquets | IP |
| :---         |     :---:      |     :---:      |     :---:      |
| dhcpDns   |  DNS maître / DHCP | Bind9 (serveur dns) / isc-dhcp-server (serveur dhcp) / dnsutils (commande dig/nslookup) | 192.168.10.5/24    |
| dnSlave     | DNS slave       | Bind9 / dnsutils / openssh-client (client ssh) / mailtutils (envoyer des mails) / mutt (créer système de messagerie)      | 192.168.10.6/24      |
| http     | HTTP       | apache2 (serveur http) / openssh-client / dnsutils / curl (faire requête GET) / git (installer script depuis git) | 192.168.10.10/24      |

# Pré-requis :

## Changer le nom de chaque machine :

-	/etc/hostname  
Remplacer “debian” par le nom de machine et son nom de domaine 
(Exemple : dhcpDns.carnofluxe.domain)


-	/etc/hosts 
Remplacer “debian” par le nom de machine et son nom de domaine
(Exemple : 127.0.1.1	dhcpDns.carnofluxe.domain).

## Installation des paquets en fonction des serveurs :

				apt-get update && apt-get upgrade
				apt-get install Apache2
				
## Mettre l’adresse ip de la machine en statique : 
-	/etc/network/interfaces

 (dans address: mettre l’ip voulue)
 
				allow-hotplug enp0s3
				iface enp0s3 inet static
				address 192.168.10.10
				netmask 255.255.255.0
				gateway 192.168.10.1


## Mettre en place le ‘’réseau NAT’’ sous VirtualBox :

•	Vérifier que la machine est bien éteinte. 
•	Fichier > Paramètres > Réseau > Ajouter un réseau NAT. 
•	Modifier le réseau NAT :
	•	Mettre l’IP réseau souhaité (ici 192.168.10.0/24).
	•	Décocher “Supporte le DHCP”.




