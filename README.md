
# Projet_Protocoles_Scripts
Le but est de  fournir une solution pour aider la société Carnofluxe à adapter son système d’information pour accueillir à terme un site de e-commerce et mettre en place des outils de supervision de ce site.




| Nom | Type serveur | Paquets | IP |
| :---         |     :---:      |     :---:      |       ---: |
| dhcpDns   |  DNS maître / DHCP | Bind9 (serveur dns) / isc-dhcp-server (serveur dhcp) / dnsutils (commande dig/nslookup) | 192.168.10.5/24    |
| dnSlave     | DNS slave       | Bind9 / dnsutils / openssh-client (client ssh) / mailtutils (envoyer des mails) / mutt (créer système de messagerie)      | 192.168.10.6/24      |
| http     | HTTP       | apache2 (serveur http) / openssh-client / dnsutils / curl (faire requête GET) / git (installer script depuis git)
      | 192.168.10.10/24      |

