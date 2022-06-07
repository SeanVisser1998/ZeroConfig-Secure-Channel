#!/bin/bash
#
#	Sean Visser
#	Cyber Security Noord-Nederland: Virtual IoT Lab
#	Script for automated setup of Netbird management-server
#	V1.1: Environment variables
#
#	https://netbird.io/docs/getting-started/self-hosting
#
#	Dependancies:
#	- Docker Compose: Netbird runs in a Docker instance (In V2 Docker Compose is included in Docker)
#	- Auth0: Netbird uses Auth0 to authenticate to the web interface
#
#	Planned updates:
#   - CLOUD-INIT INTEGRATION with ENV variables
#	- Proper variable initalization
#	- Proper parameter checking
#	- Modify existing setup.env instead of creating new one :)
#	- Less static paths etc xD
#	- Bash-style coding(UPPERCASE resembles ENV variables)
#   - Verify AUTH0 parameters 
#
# Declaring global variables
netbird_domain=$NETBIRD_DOMAIN
netbird_auth0_domain=$AUTH0_DOMAIN
netbird_auth0_client_id=$AUTH0_CLIENT_ID
netbird_auth0_audience=$AUTH0_AUDIENCE
netbird_letsencrypt_email=$LETSENCRYPT_EMAIL

function print_script_usage {
	echo "Environment variables not set! Exiting!"
} #end print_script_usage

if [[ -z $netbird_domain || -z $netbird_auth0_domain || -z $netbird_auth0_client_id || -z netbird_auth0_audience || -z netbird_letsencrypt_email ]] ; then
	print_script_usage
	exit 1
fi	

# Function to update apt repositories
function update_apt {
	sudo apt-get update
} #end update_apt

# Function to install docker
function install_docker {
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
} #end install_docker

# Function to verify docker installation has been installed correctly
# Return: 1(No succes) | 0(succes)
function verify_docker {
	echo "Verifying if docker is installed..."
	# Check if Docker is installed
	if [[ $(which docker) -ne 0 ]] ; then
		return 1 #Cri everitiem
	else
		return 0 #Success
	fi
} #end verify_docker


function download_netbird {
	#Netbird download
	REPO="https://github.com/netbirdio/netbird/"
	# this command will fetch the latest release e.g. v0.6.1
	LATEST_TAG=$(basename $(curl -fs -o/dev/null -w %{redirect_url} ${REPO}releases/latest))
	echo $LATEST_TAG

	# this comman will clone the latest tag
	git clone --depth 1 --branch $LATEST_TAG $REPO
} #end download_netbird

function configure_netbird {
	cd netbird/infrastructure_files/
	cp setup.env setup.env.bak

	sed -i 's/NETBIRD_DOMAIN=""/NETBIRD_DOMAIN="'"$netbird_domain"'"/' setup.env
	sed -i 's/NETBIRD_AUTH0_DOMAIN=""/NETBIRD_AUTH0_DOMAIN="'"$netbird_auth0_domain"'"/' setup.env
	sed -i 's/NETBIRD_AUTH0_CLIENT_ID=""/NETBIRD_AUTH0_CLIENT_ID="'"$netbird_auth0_client_id"'"/' setup.env
	sed -i 's|NETBIRD_AUTH0_AUDIENCE=""|NETBIRD_AUTH0_AUDIENCE="'"$netbird_auth0_audience"'"|' setup.env
	sed -i 's/NETBIRD_LETSENCRYPT_EMAIL=""/NETBIRD_LETSENCRYPT_EMAIL="'"$netbird_letsencrypt_email"'"/' setup.env


} #end configure_netbird

function install_netbird {
	cd netbird/infrastructure_files/
	./configure.sh
	docker compose up -d
} #end install_netbird

function run_script {
	#
	#	1. Assert Parameter lengths isnt exceeding 5 (1 fail & 0 succes)
	#	2. Assert Parameter isnt NULL
	#   3. Update APT repositories
	#	4. Install Docker
	#	5. Verify Docker installation
	#	6. Download LATEST release netbird from Github :D
	#	7. Place AUTH0 & Netbird settings in Setup.env
	#	8. Run configure.sh
	#
	
	
	#3
	update_apt
	
	#4
	install_docker
	
	#5
	if verify_docker; then
		echo "Docker is succesfully installed"
	else
		echo "Docker is not installed :("
		exit 1
	fi
	
	#6
	download_netbird
	
	#7
	configure_netbird
	
	#8
	install_netbird
} #end run_script

run_script
