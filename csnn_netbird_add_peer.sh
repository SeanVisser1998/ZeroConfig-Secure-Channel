#!/bin/bash
#
#	Sean Visser
#	Cyber Security Noord-Nederland: Virtual IoT Lab
#	Script for automated setup of Netbird peer
#	V1.0
#
#	https://netbird.io/docs/getting-started/self-hosting

sudo apt install ca-certificates curl gnupg -y
curl -L https://pkgs.wiretrustee.com/debian/public.key | sudo apt-key add -
echo 'deb https://pkgs.wiretrustee.com/debian stable main' | sudo tee /etc/apt/sources.list.d/wiretrustee.list

sudo apt-get update

sudo apt-get install netbird

if [[ $# -ne 5 ]] ; then
	print_script_usage
	exit 1

fi

if [[ -z $1 || -z $2 ]] ; then
	print_script_usage
	exit 1
fi	


sudo netbird up --management-url $1 --setup-key $2
