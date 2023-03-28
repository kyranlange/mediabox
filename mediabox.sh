#!/bin/bash

# User to run the containers as
localuname=mediabox

# Check that script was run not as root or with sudo
if [ "$EUID" -eq 0 ]
  then echo "Please do not run this script as root or using sudo"
  exit
fi

# Check if user exists
if ! id -u $localuname > /dev/null 2>&1; then
    echo "The user does not exist; execute below commands to create and try again:"
    echo "  > sudo adduser --no-create-home --shell /bin/false --group --system mediabox"
    echo "  > sudo usermod -aG docker mediabox"
    exit 1
fi

# set -x

# See if we need to check GIT for updates
if [ -e .env ]; then
    # Check for Updated Docker-Compose
    printf "Checking for update to Docker-Compose (If needed - You will be prompted for SUDO credentials).\\n\\n"
    onlinever=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d ":" -f2 | sed 's/"//g' | sed 's/,//g' | sed 's/ //g')
    printf "Current online version is: %s \\n" "$onlinever"
    localver=$(docker-compose -v | cut -d " " -f4 | sed 's/,//g')
    printf "Current local version is: %s \\n" "$localver"
    if [ "$localver" != "$onlinever" ]; then
        sudo curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url" | grep -i -m1 "$(uname -s)"-"$(uname -m)" | cut -d '"' -f4 | xargs sudo curl -L -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        printf "\\n\\n"
    else
        printf "No Docker-Compose Update needed.\\n\\n"
    fi
    # Stash any local changes to the base files
    git stash > /dev/null 2>&1
    printf "Updating your local copy of Mediabox.\\n\\n"
    # Pull the latest files from Git
    git pull
    # Check to see if this script "mediabox.sh" was updated and restart it if necessary
    changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"
    # Provide a message once the Git check/update  is complete
    if [ -z "$changed_files" ]; then
        printf "Your Mediabox is current - No Update needed.\\n\\n"
    else
        printf "Mediabox Files Update complete.\\n\\nThis script will restart if necessary\\n\\n"
    fi
    # Rename the .env file so this check fails if mediabox.sh needs to re-launch
    mv .env 1.env
    read -r -p "Press any key to continue... " -n1 -s
    printf "\\n\\n"
    # Run exec mediabox.sh if mediabox.sh changed
    grep --q "$changed_files" mediabox.sh && echo "mediabox.sh restarting" && exec $0
fi

# After update collect some current known variables
if [ -e 1.env ]; then
    # Grab the CouchPotato, NBZGet, & PIA usernames & passwords to reuse
    daemonun=$(grep CPDAEMONUN 1.env | cut -d = -f2)
    daemonpass=$(grep CPDAEMONPASS 1.env | cut -d = -f2)
    piauname=$(grep PIAUNAME 1.env | cut -d = -f2)
    piapass=$(grep PIAPASS 1.env | cut -d = -f2)
    dldirectory=$(grep DLDIR 1.env | cut -d = -f2)
    tvdirectory=$(grep TVDIR 1.env | cut -d = -f2)
    miscdirectory=$(grep MISCDIR 1.env | cut -d = -f2)
    moviedirectory=$(grep MOVIEDIR 1.env | cut -d = -f2)
    musicdirectory=$(grep MUSICDIR 1.env | cut -d = -f2)
    bookdirectory=$(grep BOOKDIR 1.env | cut -d = -f2)
    domain=$(grep DOMAIN 1.env | cut -d = -f2)
    email=$(grep EMAIL 1.env | cut -d = -f2)
    stackname=$(grep STACK_NAME 1.env | cut -d = -f2)
    pmstag=$(grep PMSTAG 1.env | cut -d = -f2)
    pmstoken=$(grep PMSTOKEN 1.env | cut -d = -f2)
    vpnremote=$(grep VPN_REMOTE 1.env | cut -d = -f2)
    # Echo back the media directories, and other info to see if changes are needed
    printf "These are the Media Directory paths currently configured.\\n"
    printf "Your DOWNLOAD Directory is: %s \\n" "$dldirectory"
    printf "Your TV Directory is: %s \\n" "$tvdirectory"
    printf "Your MISC Directory is: %s \\n" "$miscdirectory"
    printf "Your MOVIE Directory is: %s \\n" "$moviedirectory"
    printf "Your MUSIC Directory is: %s \\n" "$musicdirectory"
    printf "Your BOOK Directory is: %s \\n" "$bookdirectory"
    printf "\\n\\n"
    read  -r -p "Are these directiores still correct? (y/n) " diranswer "$(echo \n)"
    printf "\\n\\n"
    printf "Your PLEX Release Type is: %s" "$pmstag"
    printf "\\n\\n"
    read  -r -p "Do you need to change your PLEX Release Type? (y/n) " pmsanswer "$(echo \n)"
    printf "\\n\\n"
    read  -r -p "Do you need to change your PIA Credentials? (y/n) " piaanswer "$(echo \n)"
    # Now we need ".env" to exist again so we can stop just the Medaibox containers
    mv 1.env .env
    # Stop the current Mediabox stack
    printf "\\n\\nStopping Current Mediabox containers.\\n\\n"
    docker-compose stop
    # Make a datestampted copy of the existing .env file
    mv .env "$(date +"%Y-%m-%d_%H:%M").env"
fi

# Get PUID
PUID=$(id -u "$localuname")
# Get GUID
PGID=$(id -g "$localuname")
# Get Docker Group Number
DOCKERGRP=$(grep docker /etc/group | cut -d ':' -f 3)
# Get Hostname
thishost=$(hostname)
# Get IP Address
locip=$(hostname -I | awk '{print $1}')
# Get Time Zone
time_zone=$(cat /etc/timezone)	
# Get CIDR Address
slash=$(ip a | grep "$locip" | cut -d ' ' -f6 | awk -F '/' '{print $2}')
lannet=$(awk -F"." '{print $1"."$2"."$3".0"}'<<<"$locip")/$slash

# Get Private Internet Access Info
if [ -z "$piaanswer" ] || [ "$piaanswer" == "y" ]; then
read -r -p "What is your PIA Username?: " piauname
read -r -s -p "What is your PIA Password? (Will not be echoed): " piapass
printf "\\n\\n"
fi

# Get info needed for PLEX Official image
if [ -z "$pmstag" ] || [ "$pmsanswer" == "y" ]; then
read -r -p "Which PLEX release do you want to run? By default 'public' will be used. (latest, public, plexpass): " pmstag
read -r -p "If you have PLEXPASS what is your Claim Token from https://www.plex.tv/claim/ (Optional): " pmstoken
fi
# If not set - set PMS Tag to Public:
if [ -z "$pmstag" ]; then
   pmstag=public
fi

# Ask user if they already have TV, Movie, and Music directories
if [ -z "$diranswer" ]; then
printf "\\n\\n"
printf "If you already have TV - Movie - Music directories you want to use you can enter them next.\\n"
printf "If you want Mediabox to generate it's own directories just press enter to these questions."
printf "\\n\\n"
read -r -p "Where do you store your DOWNLOADS? (Please use full path - /path/to/downloads ): " dldirectory
read -r -p "Where do you store your TV media? (Please use full path - /path/to/tv ): " tvdirectory
read -r -p "Where do you store your MISC media? (Please use full path - /path/to/misc ): " miscdirectory
read -r -p "Where do you store your MOVIE media? (Please use full path - /path/to/movies ): " moviedirectory
read -r -p "Where do you store your MUSIC media? (Please use full path - /path/to/music ): " musicdirectory
read -r -p "Where do you store your BOOK media? (Please use full path - /path/to/books ): " bookdirectory
fi
if [ "$diranswer" == "n" ]; then
read -r -p "Where do you store your DOWNLOADS? (Please use full path - /path/to/downloads ): " dldirectory
read -r -p "Where do you store your TV media? (Please use full path - /path/to/tv ): " tvdirectory
read -r -p "Where do you store your MISC media? (Please use full path - /path/to/misc ): " miscdirectory
read -r -p "Where do you store your MOVIE media? (Please use full path - /path/to/movies ): " moviedirectory
read -r -p "Where do you store your MUSIC media? (Please use full path - /path/to/music ): " musicdirectory
read -r -p "Where do you store your BOOK media? (Please use full path - /path/to/books ): " bookdirectory
fi

mkdir -p delugevpn
mkdir -p delugevpn/config/openvpn
mkdir -p glances
#mkdir -p filebrowser
#mkdir -p flaresolverr
mkdir -p historical/env_files
mkdir -p homepage
# mkdir -p homer
mkdir -p jackett
mkdir -p lidarr
mkdir -p metube
mkdir -p sabnzbdvpn/config/openvpn
mkdir -p ombi
#mkdir -p overseerr
mkdir -p "plex/Library/Application Support/Plex Media Server/Logs"
mkdir -p portainer
#mkdir -p prowlarr
mkdir -p radarr
#mkdir -p requestrr
mkdir -p sonarr
mkdir -p lazylibrarian
mkdir -p speedtest
mkdir -p tautulli
#mkdir -p tdarr
#mkdir -p tubesync

if [ -z "$vpnremote" ]; then
    # Create menu - Select and Move the PIA VPN files
    echo "The following PIA Servers are avialable that support port-forwarding (for DelugeVPN and SabnzbdVPN); Please select one:"
    PS3="Use a number to select a Server File or 'c' to cancel: "
    # List the ovpn files
    select filename in ovpn/*.ovpn
    do
        # leave the loop if the user says 'c'
        if [[ "$REPLY" == c ]]; then break; fi
        # complain if no file was selected, and loop to ask again
        if [[ "$filename" == "" ]]
        then
            echo "'$REPLY' is not a valid number"
            continue
        fi
        # now we can use the selected file
        echo "$filename selected"
        # remove any existing ovpn, crt & pem files in the deluge config/ovpn
        rm delugevpn/config/openvpn/*.ovpn > /dev/null 2>&1
        rm delugevpn/config/openvpn/*.crt > /dev/null 2>&1
        rm delugevpn/config/openvpn/*.pem > /dev/null 2>&1
        # remove any existing ovpn, crt & pem files in the sabnzbd config/ovpn
        rm sabnzbdvpn/config/openvpn/*.ovpn > /dev/null 2>&1
        rm sabnzbdvpn/config/openvpn/*.crt > /dev/null 2>&1
        rm sabnzbdvpn/config/openvpn/*.pem > /dev/null 2>&1
        # copy the selected ovpn file to deluge & sabnzbd config/ovpn
        cp "$filename" delugevpn/config/openvpn/ > /dev/null 2>&1
        cp "$filename" sabnzbdvpn/config/openvpn/ > /dev/null 2>&1

        vpnremote=$(grep "remote" "$filename" | cut -d ' ' -f2  | head -1)
        # Adjust for the PIA OpenVPN ciphers fallback
        echo "cipher aes-256-gcm" >> delugevpn/config/openvpn/*.ovpn
        echo "cipher aes-256-gcm" >> sabnzbdvpn/config/openvpn/*.ovpn
        # it'll ask for another unless we leave the loop
        break
    done
    # TODO - Add a default server selection if none selected ..
    cp ovpn/*.crt delugevpn/config/openvpn/ > /dev/null 2>&1
    cp ovpn/*.pem delugevpn/config/openvpn/ > /dev/null 2>&1
    cp ovpn/*.crt sabnzbdvpn/config/openvpn/ > /dev/null 2>&1
    cp ovpn/*.pem sabnzbdvpn/config/openvpn/ > /dev/null 2>&1
fi

# Create the .env file
echo "Creating the .env file with the values we have gathered"
printf "\\n"
cat << EOF > .env
###  ------------------------------------------------
###  M E D I A B O X   C O N F I G   S E T T I N G S
###  ------------------------------------------------
###  The values configured here are applied during
###  $ docker-compose up
###  -----------------------------------------------
###  DOCKER-COMPOSE ENVIRONMENT VARIABLES BEGIN HERE
###  -----------------------------------------------
###
EOF
{
echo "LOCALUSER=$localuname"
echo "HOSTNAME=$thishost"
echo "IP_ADDRESS=$locip"
echo "PUID=$PUID"
echo "PGID=$PGID"
echo "DOCKERGRP=$DOCKERGRP"
echo "PWD=$PWD"
echo "DLDIR=$dldirectory"
echo "TVDIR=$tvdirectory"
echo "MISCDIR=$miscdirectory"
echo "MOVIEDIR=$moviedirectory"
echo "MUSICDIR=$musicdirectory"
echo "BOOKDIR=$bookdirectory"
echo "PIAUNAME=$piauname"
echo "PIAPASS=$piapass"
echo "CIDR_ADDRESS=$lannet"
echo "TZ=$time_zone"
echo "PMSTAG=$pmstag"
echo "PMSTOKEN=$pmstoken"
echo "VPN_REMOTE=$vpnremote"
} >> .env
echo ".env file creation complete"
printf "\\n\\n"

# Move back-up .env files
mv 20*.env historical/env_files/ > /dev/null 2>&1
mv historical/20*.env historical/env_files/ > /dev/null 2>&1

# Adjust for removal of Muximux
docker rm -f muximux > /dev/null 2>&1
[ -d "muximux/" ] && mv muximux/ historical/muximux/

# Download & Launch the containers
echo "The containers will now be pulled and launched"
echo "This may take a while depending on your download speed"
read -r -p "Press any key to continue... " -n1 -s
printf "\\n\\n"
docker-compose up -d --remove-orphans
printf "\\n\\n"

# Configure the access to the Deluge Daemon
# The same credentials can be used for NZBGet's webui
if [ -z "$daemonun" ]; then
echo "You need to set a username and password for programs to access"
echo "the Deluge daemon."
read -r -p "What would you like to use as the access username?: " daemonun
read -r -p "What would you like to use as the access password?: " daemonpass
printf "\\n\\n"
fi

# Finish up the config
printf "Configuring DelugeVPN, Muximux, and Permissions \\n"
printf "This may take a few minutes...\\n\\n"

# Configure DelugeVPN: Set Daemon access on, delete the core.conf~ file
while [ ! -f delugevpn/config/core.conf ]; do sleep 1; done
docker stop delugevpn > /dev/null 2>&1
rm delugevpn/config/core.conf~ > /dev/null 2>&1
perl -i -pe 's/"allow_remote": false,/"allow_remote": true,/g'  delugevpn/config/core.conf
perl -i -pe 's/"move_completed": false,/"move_completed": true,/g'  delugevpn/config/core.conf
docker start delugevpn > /dev/null 2>&1

# Push the Deluge Daemon Access info the to Auth file and to the .env file
echo "$daemonun":"$daemonpass":10 >> ./delugevpn/config/auth
{
echo "CPDAEMONUN=$daemonun"
echo "CPDAEMONPASS=$daemonpass"
} >> .env

# Configure Homepage settings and files
while [ ! -f homepage/services.yaml ]; do sleep 1; done
docker stop homepage > /dev/null 2>&1
cp prep/services.yaml homepage/services.yaml
cp prep/settings.yaml homepage/settings.yaml
cp prep/docker.yaml homepage/docker.yaml
cp prep/bookmarks.yaml homepage/bookmarks.yaml
perl -i -pe "s/locip/$locip/g" homepage/services.yaml
perl -i -pe "s/daemonpass/$daemonpass/g" homepage/services.yaml
perl -i -pe "s/thishost/$thishost/g" homepage/settings.yaml
# sed '/^PIA/d' < .env > homer/env.txt # Pull PIA creds from the displayed .env file
docker start homepage > /dev/null 2>&1

# Create Port Mapping file
# for i in $(docker ps --format {{.Names}} | sort); do printf "\n === $i Ports ===\n" && docker port "$i"; done > homer/ports.txt

# Completion Message
printf "Setup Complete - Open a browser and go to: \\n\\n"
printf "http://%s \\nOR http://%s If you have appropriate DNS configured.\\n\\n" "$locip" "$thishost"
printf "Start with the MEDIABOX Icon for settings and configuration info.\\n"
