# ZeroConfig-Secure-Channel
Het ontwikkelen van een ZeroConfig client-to-client secure channel tussen twee NATed netwerken

Credits: https://github.com/netbirdio/netbird

Project doelen:
- OpenSource code en documentatie
- Secure by Design
- (Bijna) gratis in gebruik
- Gemakkelijk te gebruiken, zelfs voor niet-technisch ingestelde individuelen
- Schaalbaar 

Benodigdheden:
- Gratis AUTH0 account
- Twee apparaten die een Peer-to-Peer verbinding willen
- Server 
- Domein naam

Dependancies:
- Docker
- Netbird
- Auth0

Installatie Netbird server:
1. Log in op de server waarop de Netbird management server dient te komen
2. git clone https://github.com/SeanVisser1998/ZeroConfig-Secure-Channel.git
3. chmod +x csnn_netbird.sh
4. ./csnn_netbird.sh <domein_naam> <auth0_domein_naam> <auth0_client_id> <auth0_audience> <letsencrypt_email>

Peer toevoegen aan management server:
1. Log in op de peer die toegevoegd dient te worden aan de Netbird management server
2. git clone https://github.com/SeanVisser1998/ZeroConfig-Secure-Channel.git
3. chmod +x csnn_netbird_add_peer.sh
4. ./csnn_netbird_add_peer.sh <domein_netbird_server:poort_netbird_server> <netbird_setup_key>
5. Default poort_netbird_server = 33071
