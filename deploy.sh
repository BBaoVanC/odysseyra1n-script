#!/bin/sh

if [ "$(uname -s)" = "Darwin" ]; then
    if [ "$(uname -p)" = "arm" ] || [ "$(uname -p)" = "arm64" ]; then
        echo "It's recommended this script be ran on macOS/Linux with a clean iOS device running checkra1n attached unless migrating from older bootstrap."
        printf "Press enter to continue"
        read -r a
        ARM=yes
    fi
fi

echo "odysseyra1n deployment script"
echo "(C) 2020, CoolStar. All Rights Reserved"
echo "    Semi-rewrite by bbaovanc"

echo ""
echo "Before you begin: This script includes experimental migration from older bootstraps to Procursus/Odyssey."
echo "If you're already jailbroken, you can run this script on the checkra1n device."
echo "If you'd rather start clean, please Reset System via the Loader app first."
printf "Press enter to continue"
read -r a  # needs to have a variable to read into, so I picked a

! command -v "curl" > /dev/null 2>&1 && echo "curl is required!" && exit 1

if [ "$ARM" = "yes" ]; then
    ! command -v "zsh" > /dev/null 2>&1 && echo "zsh is required!" && exit 1
else
    if ! command -v "iproxy" > /dev/null 2>&1; then
        echo "iproxy is required"
        exit 1
    else
        iproxy 4444 44 > /dev/null 2>&1 &
    fi
fi

rm -rfv /tmp/odyssey-tmp
mkdir -v /tmp/odyssey-tmp
cp -v device-deploy.sh.template /tmp/odyssey-tmp/device-deploy.sh
cd /tmp/odyssey-tmp || exit 1

if [ "$ARM" = "yes" ]; then
    sed -i 's/^#IFARM //' device-deploy.sh
    sed -i '/^#IFNOTARM /d' device-deploy.sh
else
    sed -i '/^#IFARM /d' device-deploy.sh
    sed -i 's/^#IFNOTARM //' device-deploy.sh
fi

echo "Downloading Resources..."
curl -L -O https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1500.tar.gz -O https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1600.tar.gz -O https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1700.tar.gz -O https://github.com/coolstar/odyssey-bootstrap/raw/master/migration -O https://github.com/coolstar/odyssey-bootstrap/raw/master/org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb -O https://github.com/coolstar/odyssey-bootstrap/raw/master/org.swift.libswift_5.0-electra2_iphoneos-arm.deb

if [ ! "$ARM" = "yes" ]; then
    echo "Copying Files to your device"
    echo "Default password is: alpine"
    scp -P4444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" bootstrap_1500.tar.gz bootstrap_1600.tar.gz bootstrap_1700.tar.gz migration org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb org.swift.libswift_5.0-electra2_iphoneos-arm.deb device-deploy.sh root@127.0.0.1:/var/root/
fi

echo "Installing Procursus bootstrap and Sileo on your device"
if [ "$ARM" = "yes" ]; then
    zsh ./device-deploy.sh
else
    echo "Default password is: alpine"
    ssh -p4444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" root@127.0.0.1 "zsh /var/root/device-deploy.sh"
    echo "All Done!"
    killall iproxy
fi
