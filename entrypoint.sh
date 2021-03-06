#!/bin/bash -x
cd /home/container
sleep 1
# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update Source Server
if [ ! -z ${SRCDS_APPID} ]; then
    if [ ! -z ${SRCDS_BETAID} ]; then
        if [ ! -z ${SRCDS_BETAPASS} ]; then
            ./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update ${SRCDS_APPID} -beta ${SRCDS_BETAID} -betapassword ${SRCDS_BETAPASS} +quit
        else
            ./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update ${SRCDS_APPID} -beta ${SRCDS_BETAID} +quit
        fi
    else
        ./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update ${SRCDS_APPID} +quit
    fi
fi

# Update AMXX Plugins
if [ -d /home/container/tfc/addons/amxmodx/plugins/.git/ ]; then
	cd /home/container/tfc/addons/amxmodx/plugins
	git clean -dxf
	git pull origin master
else
	if [ -d /home/container/tfc/addons/amxmodx/ ]; then 
		rm -rf /home/container/tfc/addons/amxmodx/plugins
		cd /home/amxmodx/container/tfc/addons/amxmodx
		git clone https://github.com/ESClan/plugins.git
	fi
fi
cd /home/container
sleep 1

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
