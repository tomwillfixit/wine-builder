#!/bin/bash

# Takes one argument; Location of a League Installer .exe stored locally or a http link to one which can be downloaded. For example :
# http://l3cdn.riotgames.com/releases/live/installer/League%20of%20Legends%20installer%20EUW.exe

set -e

xhost +

timestamp=$(date +"%T")

echo "The purpose of this script is to extract the league installer .exe into a directory which will can be used to run League from Wine."

echo "Pre install cleanup"

docker rm -f exe_extractor 2>/dev/null ||true

league_installer_exe="$1"

if [[ "${league_installer_exe}" = *http* ]]; then
    echo "Downloading .exe from : ${league_installer_exe}"
    echo "and renaming to lol.exe"
    wget -O lol.exe "${league_installer_exe}"
    league_installer_exe="lol.exe"
fi

if [[ $# -ne 1 ]]; then
    echo "Expecting 1 argument : League of Legends Installer .exe filename"
    exit 1
fi

if [ ! -f ${league_installer_exe} ];then
    echo "${league_installer_exe} does not exist. Exiting"
    exit 1
fi

echo "Select Windows XP compatibility Mode"
sleep 2

docker run -it -v /tmp/.X11-unix:/tmp/.X11-unix \
               -v $(pwd)/${league_installer_exe}:/var/tmp/${league_installer_exe} \
               -e DISPLAY=unix$DISPLAY \
               -e WINEPREFIX=/var/tmp/LoL_installed \
               -e WINEDLLOVERRIDES="mscoree,mshtml=" \
               -e WINEDEBUG=-all \
               --name exe_extractor \
               patched_wine:latest /bin/bash -c "/tmp/wine/usr/local/bin/winecfg ; /tmp/wine/usr/local/bin/wine /var/tmp/${league_installer_exe} --mode unattended ; sleep 20"

if [ -d ./LoL_installed ];then
    echo "LoL_installed directory already exists in `pwd`"
    echo "Moving to LoL_installed_${timestamp}"
    mv LoL_installed LoL_installed_${timestamp}
fi

docker cp exe_extractor:/var/tmp/LoL_installed .

echo "${league_installer_exe} installed into LoL_installed"

echo "Post extraction cleanup"

echo "Removing dosdevices and users/root/My* directories since they are not needed."

rm -rf ./LoL_installed/dosdevices* 
rm -rf ./LoL_installed/drive_c/users/root/My*

ls -l ./LoL_installed/*

