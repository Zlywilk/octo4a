#!/bin/bash
set -e
COL='\033[1;32m'
NC='\033[0m' # No Color
echo -e "${COL}Setting up moonraker"

read -p "Do you have \"Plugin extras\" installed? (y/n): " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${COL}\nPlease go to settings and install plugin extras${NC}"
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo -e "${COL}Installing dependencies...\n${NC}"
# install required dependencies
apk add patch  curl-dev libressl-dev python3-dev jpeg-dev zlib-dev py3-virtualenv openjpeg libgpiod lmdb libsodium zlib libjpeg 
echo -e "${COL}Downloading moonraker\n${NC}"
curl -o moonraker.zip -L https://github.com/Arksine/moonraker/archive/refs/heads/master.zip

echo -e "${COL}Extracting moonraker\n${NC}"
unzip moonraker.zip
rm -rf moonraker.zip


mv moonraker-master /moonraker
echo -e "${COL}Create virtual env\n${NC}"
virtualenv -p python3 .moonraker_env
echo -e "${COL}Use env\n${NC}"
chmod +x /root/.moonraker_env/bin/*
chmod 777 /root/.moonraker_env/bin/*
source "/root/.moonraker_env/bin/activate"
python -m ensurepip --default-pip
echo -e "${COL}Update pip \n${NC}"
/root/.moonraker_env/bin/python3 -m pip install  --upgrade pip
echo -e "${COL}Installing pip dependencies...\n${NC}"
/root/.moonraker_env/bin/python3 -m pip install  -r /moonraker/scripts/moonraker-requirements.txt

mkdir -p /root/extensions/moonraker
cat << EOF > /root/extensions/moonraker/manifest.json
{
        "title": "moonraker plugin",
        "description": "Requires kliper plugin"
}
EOF

cat << EOF > /root/extensions/moonraker/start.sh
#!/bin/sh
source "/root/.moonraker_env/bin/activate"
/root/.moonraker_env/bin/python3 /moonraker/moonraker/moonraker.py
EOF

cat << EOF > /root/extensions/moonraker/kill.sh
#!/bin/sh
pkill -f 'moonraker\.py'
EOF
chmod +x /root/extensions/moonraker/start.sh
chmod +x /root/extensions/moonraker/kill.sh
chmod 777 /root/extensions/moonraker/start.sh
chmod 777 /root/extensions/moonraker/kill.sh

echo -e "${COL}\nmoonraker installed! Please kill the app and restart it again to see it in extension settings${NC}"