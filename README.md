# ZeroConfig-Secure-Channel
Het ontwikkelen van een ZeroConfig client-to-client secure channel tussen twee NATed netwerken

Credits: https://github.com/netbirdio/netbird

Leeswaardig:
- https://netbird.io/docs/getting-started/self-hosting
- https://docs.docker.com/compose/install/
- https://auth0.com/docs/quickstart/spa/react/01-login#configure-auth0

Project doelen:
- OpenSource code en documentatie
- Secure by Design
- (Bijna) gratis in gebruik
- Gemakkelijk te gebruiken, zelfs voor niet-technisch ingestelde individuelen
- Schaalbaar 

Benodigdheden:
- Gratis AUTH0 account
- Twee apparaten die een Peer-to-Peer verbinding willen
- Server met poorten 443, 33071, 33073 & 10000 open. (Standaard poorten van Netbird)
- Domein naam

Dependancies:
- Docker
- Netbird
- Auth0

Installatie Netbird Management Server:
1. Open poort 443, 33071, 33073 & 10000 op de firewall
2. Pas < USER SSH KEY > naar de PUBLIC key die geautoriseerd is om te loggen op de Management Server aan in cloud-config
3. Voeg de juiste variabelen toe aan NETBIRD_DOMAIN, AUTH0_DOMAIN, AUTH0_CLIENT_ID, AUTH0_AUDIENCE & LETSENCRYPT_EMAIL in cloud-config
4. Plaats cloud-config op de server VOOR de eerste boot
5. Netbird management server wordt nu automatisch ingesteld na de eerste boot

Peer toevoegen aan management server:
1. Pas < USER SSH KEY > naar de PUBLIC key die geautoriseerd is om te loggen op de Peer aan in cloud-config
2. Voeg de juiste variabelen toe aan NETBIRD_DOMAIN, AUTH0_DOMAIN, AUTH0_CLIENT_ID, AUTH0_AUDIENCE & LETSENCRYPT_EMAIL in cloud-config
3. Plaats cloud-config op de peer VOOR de eerste boot
4. De peer wordt automatisch toegevoegd aan de management server na de eerste boot

!!BELANGRIJK WANNEER PEER WORDT INGERICHT OP RASPBERY PI OF ANDER APPARAAT WAT VAN NETWERK KAN WISSELEN!!

Elke keer dat van netwerk verwisselt wordt, wordt de P2P verbinding verbroken. Wanneer de Raspberry Pi bijvoorbeeld naar een klant gestuurd wordt, is een workaround: Voer het opzetten van de Netbird verbinding uit in CRON job bij boot en/of wisseling van netwerk
