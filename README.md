
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
-	Vérifier que la machine est bien éteinte. 
-	Fichier > Paramètres > Réseau > Ajouter un réseau NAT. 
-	Modifier le réseau NAT :
	*	Mettre l’IP réseau souhaité (ici 192.168.10.0/24).
	*	Décocher “Supporte le DHCP”.
	
	
# Serveur DNS maître et DHCP

## Serveur DHCP 

-	/etc/dhcp/dhcpd.conf

		subnet 192.168.10.0 netmask 255.255.255.0 {
		range 192.168.10.100 192.168.10.200;
		option broadcast-address 192.168.10.255;
		option routers 192.168.10.1;
		option domain-name “carnofluxe.domain”;
		option domain-name-servers 192.168.10.5, 192.168.10.6;
		default-lease-time 600;
		max-lease-time 7200;
}

-	/etc/defautl/isc-dhcp-server

		INTERFACESv4="enp0s3"

-	/etc/init.d/isc-dhcp-server restart


## Serveur DNS Maitre

-	/etc/bind/named.conf.local

		zone “carnofluxe.domain” {
			type master;
			also-notify { 192.168.10.6; };
			allow-transfer { 192.168.10.6; };
			allow-update { none; };
			allow-query { any; };
			notify yes;
			file “/etc/bind/db.carnofluxe.domain”;
		};

		zone “10.168.192.in-addr.arpa” {
			type master;
			also-notify { 192.168.10.6; };
			allow-transfer { 192.168.10.6; };
			allow-update { none; };
			allow-query { any; };
			notify yes;
			file “/etc/bind/db.10.168.192.in-addr.arpa”;
		};





-	/etc/bind/named.conf.options

		options {
			directory "/var/cache/bind";
			allow-transfer { 192.168.10.6; };
		};


-	/etc/bind/db.carnofluxe.domain

		$TTL	604800
		@	IN	SOA	carnofluxe.domain.	root.carnofluxe.domain.	(
			1		; Serial
			604800	; Refresh
			86400		; Retry
			2419200	; Expire
			604800 )	; Negative Cache TTL
		;
		@		IN	NS	dhcpDns.
		dhcpDns.	IN	A	192.168.10.5
		www		IN	A	192.168.10.10
		supervision	IN	A	192.168.10.10







-	/etc/bind/db.10.168.192.in-addr.arpa

		$TTL	604800
		@	IN	SOA	10.168.192.in-addr.arpa.	root.10.168.192.in-addr.arpa.	(
			2		; Serial
			604800	; Refresh
			86400		; Retry
			2419200	; Expire
			6048100 )	; Negative Cache TTL
		; 10.168.192.in-addr.arpa	IN	NS	dhcpDns.carnofluxe.domain
		5	IN	PTR	carnofluxe.domain
		5	IN	PTR	dhcpDns.carnofluxe.domain
		10	IN	PTR	www.carnofluxe.domain
		10	IN	PTR	supervision.carnofluxe.domain



-	named-checkconf -z 
Permet de vérifier la syntaxe des fichiers bind9.

-	service bind9 restart
Permet de relancer bind9 pour appliquer les modifications.


Serveur DNS esclave

-	/etc/bind/named.conf.local

		zone  “carnofluxe.domain” {
			type slave;
			masters {192.168.10.5;};
			file “/var/lib/bind/db.carnofluxe.domain”;
		};

		zone “10.168.192.in-addr.arpa” {
			type slave;
			masters {192.168.10.5;};
			file “/var/lib/bind/db.10.168.192.in-addr.arpa”;
		};


-	named-checkconf -z 
Permet de vérifier la syntaxe des fichiers bind9.

-	service bind9 restart 
Permet de relancer bind9 pour appliquer les modifications.

-	Vérifier que les fichiers ont bien été copié dans : /var/lib/bind.


# Serveur HTTP

## Configuration des VirtualHosts : 

-	/etc/apache2/000-default.conf

		<VirtualHost *:80>
		ServerAdmin webmaster@localhost
			DocumentRoot /var/www

			ErrorLog ${APACHE_LOG_DIR}/error.log
			CustomLog ${APACHE_LOG_DIR}/access.log combined
		</VirtualHost>


-	/etc/apache2/sites-available/carnofluxe.domain.conf

		<VirtualHost *:80>
		ServerName www.carnofluxe.domain
		ServerAlias carnofluxe.domain
		DocumentRoot /var/www/carnofluxe
		DirectoryIndex index.html

		<Directory /var/www/carnofluxe/>
		Require all granted
		AllowOverride All
		</Directory>
		</VirtualHost>

		<VirtualHost *:80>
		ServerName supervision.carnofluxe.domain
		ServerAlias supervision.domain
		DocumentRoot /var/www/supervision
		DirectoryIndex index.html

			<Directory /var/www/supervision/>
		Require all granted
		AllowOverride All
		</Directory>
		</VirtualHost>





