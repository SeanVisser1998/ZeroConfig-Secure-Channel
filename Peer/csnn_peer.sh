#!/bin/bash
#
#	Sean Visser
#	Cyber Security Noord-Nederland: Virtual IoT Lab
#	Script for automated setup of Netbird peer on Ubuntu 20.04
#	V1.1: Environment variables
#
#	https://netbird.io/docs/getting-started/self-hosting
#
#	Dependancies:
#	- Docker Compose: Netbird runs in a Docker instance (In V2 Docker Compose is included in Docker)
#	- Auth0: Netbird uses Auth0 to authenticate to the web interface
#

# Declaring global variables
# NOTE: !Could be removed because variables are stored in ENV!
netbird_domain=$NETBIRD_DOMAIN
netbird_port=$NETBIRD_PORT
netbird_setup_key=$NETBIRD_SETUP_KEY

function print_script_usage {
	echo "Environment variables not set! Exiting!"
}

#Adding netbird repository
function add_netbird_repo {
	sudo apt install ca-certificates curl gnupg -y
	curl -L https://pkgs.wiretrustee.com/debian/public.key | sudo apt-key add -
	echo 'deb https://pkgs.wiretrustee.com/debian stable main' | sudo tee /etc/apt/sources.list.d/wiretrustee.list
} #end add_netbird_repo

function apt_update {
	sudo apt-get update
} #end apt_update

function install_netbird {
	sudo apt-get install netbird
} #end install_netbird

function env_var_check {
#Only checks if its not NULL atm, proper checks are planned to be implemented in later stages
	if [[ -z $netbird_domain || -z $netbird_port || $netbird_setup_key ]] ; then
		print_script_usage
		exit 1
	fi
} #end env_var_check

function add_peer_to_management_server {
	sudo netbird up --management-url https://${netbird_domain}:${netbird_port} --setup-key ${netbird_setup_key}
} #end add_peer_to_management_server

function run_script {
	#env_var_check
	add_netbird_repo
	apt_update
	install_netbird
	add_peer_to_management_server
} #end run_script

run_script


