#!/bin/bash
#
#   Sean Visser
#	Cyber Security Noord-Nederland: Virtual IoT Lab
#
#   Assumption has been made that this script will run ON THE SAME MACHINE AS MANAGEMENT SERVER,
#   so it shares the ENV path
#
#   Section 1: SSH keys for User-Authorized-Keys
#

gen_pass=""
public_key=""
encrypted_private_key=""
hostname=$1
# Two PA
function generate_key_pair() {
    echo $#
    if [[ $# -ne 2 ]]; then
        echo "Invalid argument length passed to generate_key_pair. Exiting..."
        exit 1
    fi

    file_name=$1
    private_key_password=$2
    ssh-keygen -t ed25519 -f ${file_name} -q -N "${private_key_password}"
} #end generate_key_pair()

# One PA
function get_generated_public_key() {
#Gets generated public key in string format for easier pasting with sed in cloud-config file
    if [[ $# -ne 1 ]]; then
        echo "Invalid argument length passed to get_generated_public_key. Exiting..."
        exit 1
    fi
    file_name=$1

    public_key=$(cat ${file_name}.pub)
} #end get_generated_public_key()

#One PA
function get_generated_private_key() {
#Gets generated encrypted private key in string format for easier pasting with sed in cloud-config file
    if [[ $# -ne 1 ]]; then
        echo "Invalid argument length passed to get_generated_private_key. Exiting..."
        exit 1
    fi
    file_name=$1

    encrypted_private_key=$(cat ${file_name})
} #end get_generated_private_key()

function generate_password_keys() {
#Generate a 12 character psuedo-random password to encrypt the private key with
    gen_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
} #end generate_password_keys()

# One PA
function add_hostname_to_cloud_config(){
    if [[ $# -ne 1 ]]; then
	echo "Invaled argument length passed to add_host_name_to_cloud_config. Exiting..."
	exit 1
    fi

    sed -i "s|<HOSTNAME>|${hostname}|" $1
}

# One PA
function add_public_key_to_cloud_config(){
    if [[ $# -ne 1 ]]; then
        echo "Invalid argument length passed to add_public_key_to_cloud_config. Exiting..."
        exit 1
    fi

    sed -i "s|<USER SSH KEY>|${public_key}|" $1
} #end add_public_key_to_cloud_config

# One PA
function export_encrypted_private_key() {
    if [[ $# -ne 1 ]]; then
        echo "Invalid argument length passed to export_encrypted_private_key. Exiting..."
        exit 1
    fi
    
    # ATM print it on screen, but would be nicer to have it sent somewhere else where only the customer can read it.
    echo ""
    echo ""
    echo "!!! Private key encryption password: "
    echo $gen_pass
    echo "!!! Please write down the private key encryption password !!!"
    echo "You can find the key pair under $1"
    echo ""
    echo ""
}

#
#   Section 2: Netbird domain to cloud-config.
#

# One PA
function add_netbird_domain_cloud_config(){
    if [[ $# -ne 1 ]]; then
        echo "Invalid argument length passed to add_netbird_domain_cloud_config. Exiting..."
        exit 1
    fi
    sed -i 's|NETBIRD_DOMAIN=""|NETBIRD_DOMAIN="'"$NETBIRD_DOMAIN"'"|' $1
}

#
#   Section 3: Netbird setup-key to cloud-config. Really really really hard. Infeasable due to time restraints for now
#

# Two PA
function add_setup_key_cloud_config(){

    #
    #   Netbird setup-keys are stored in structs within Go AND in file (store.json), all within Docker container :): I CRI Not feasible given time constraints, sowwy Jos OwO
    #   workaround: When user runs script, ask them for setup key 
    #
    if [[ $# -ne 2 ]]; then
        echo "Invalid argument length passed to get_valid_setup_key. Exiting..."
        exit 1
    fi
    setup_key=$1
    sed -i 's|NETBIRD_SETUP_KEY=""|NETBIRD_SETUP_KEY="'"${setup_key}"'"|' $2
}

function query_user_setup_key(){

    echo "Please provide a valid Netbird setup key from ${NETBIRD_DOMAIN}"
    read setup_key_in
    echo "Your setup key is ${setup_key_in}, correct? (Y | N)"
    read confirm_thing 
    if [[ ${confirm_thing^^} != "YES" || ${confirm_thing^^} != "Y" ]]; then
        echo "Okay, let's try again "
        query_user_setup_key
    fi

    echo "Okay thank you for confirming ${setup_key_in} is a valid Netbird setup_key from ${NETBIRD_DOMAIN}"
    return setup_key_in    
}

#
#   Section 4: Netbird port to cloud-config file. 
#
function add_netbird_port_cloud_config(){
    if [[ $# -ne 2 ]]; then
        echo "Invalid argument length passed to add_netbird_port_cloud_config. Exiting..."
        exit 1
    fi

    netbird_port=$1
    sed -i 's|NETBIRD_PORT=""|NETBIRD_PORT="'"${netbird_port}"'"|' $2
}

#
#   Section 5: stitching everything together
#
function new_raspberry_pi(){

    if [[ $# -ne 2 ]]; then
        echo "Invalid argument length passed to new_raspberry_pi. Exiting..."
        exit 1
    fi

    generate_password_keys

    name=$1
    setup_key=$2
    cloud_init_template="cloud-config-peer-template"

    cp ${cloud_init_template} cloud_init_${name}

    cloud_init_file=cloud_init_${name}

    # Generating password to encrypt private key with 
    generate_key_pair $name $gen_pass
    get_generated_public_key $name
    get_generated_private_key $name

    add_hostname_to_cloud_config $cloud_init_file

    #Getting the public key
    add_public_key_to_cloud_config $cloud_init_file

    #Getting the encrypted private key
    export_encrypted_private_key $name

    #Adding netbird_domain to cloud-config file
    add_netbird_domain_cloud_config $cloud_init_file


    # Setup key is required for the user to put in, due to the setup key being stored in GoLang structs or store.json in a Docker environment, not feasible to implement this 
    # given current time restraints

    add_setup_key_cloud_config $setup_key $cloud_init_file

    # Adding Netbird port to cloud-init
    add_netbird_port_cloud_config 33073 $cloud_init_file

    echo "Cloud-config file is sucessfully filled out for ${name} in ${cloud_init_file} :D"

}

    if [[ $# -ne 2 ]]; then
        echo "Usage: ./${0} <name_new_raspberry_pi> <netbird-setup-key>"
        exit 1
    fi

new_raspberry_pi $1 $2 $gen_pass
