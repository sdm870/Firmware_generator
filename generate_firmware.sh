#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install aria2c
install_aria2c() {
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y aria2
    elif command_exists dnf; then
        sudo dnf install -y aria2
    elif command_exists yum; then
        sudo yum install -y aria2
    elif command_exists pacman; then
        sudo pacman -Sy --noconfirm aria2
    elif command_exists zypper; then
        sudo zypper install -y aria2
    else
        echo "Unable to install aria2c. Please install it manually."
        exit 1
    fi
}

# Check if aria2c is installed, if not, install it
if ! command_exists aria2c; then
    echo "aria2c is not installed. Installing..."
    install_aria2c
fi

arch=$(arch)
if [ "$arch" == "x86_64" ]; then
    arch="amd64"
elif [ "$arch" == "aarch64" ]; then
    arch="arm64"
fi

payload_link="https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_linux_$arch.tar.gz"
zips="https://cdn-ota.azureedge.net/V14.0.5.0.TKHINXM/miui_ALIOTHINGlobal_V14.0.5.0.TKHINXM_2b58e06a45_13.0.zip
      https://cdn-ota.azureedge.net/V14.0.11.0.TKHEUXM/miui_ALIOTHEEAGlobal_V14.0.11.0.TKHEUXM_067e9d6f67_13.0.zip
      https://cdn-ota.azureedge.net/V14.0.8.0.TKHMIXM/miui_ALIOTHGlobal_V14.0.8.0.TKHMIXM_4baed81b95_13.0.zip
      https://cdn-ota.azureedge.net/V14.0.4.0.TKHIDXM/miui_ALIOTHIDGlobal_V14.0.4.0.TKHIDXM_b6fecb3025_13.0.zip
      https://cdn-ota.azureedge.net/V14.0.3.0.TKHRUXM/miui_ALIOTHRUGlobal_V14.0.3.0.TKHRUXM_966287acb9_13.0.zip
      https://cdn-ota.azureedge.net/V14.0.3.0.TKHTWXM/miui_ALIOTHTWGlobal_V14.0.3.0.TKHTWXM_4aabc516ec_13.0.zip
      https://cdn-ota.azureedge.net/V14.0.3.0.TKHTRXM/miui_ALIOTHTRGlobal_V14.0.3.0.TKHTRXM_a03307201d_13.0.zip
      https://cdn-ota.azureedge.net/V14.0.8.0.TKHCNXM/miui_ALIOTH_V14.0.8.0.TKHCNXM_50141f32f2_13.0.zip"

echo "Downloading payload dumper..."
aria2c --file-allocation=none -x 16 "$payload_link"
tar -xf payload-dumper-go_*.tar.gz payload-dumper-go && rm payload-dumper-go_*.tar.gz

partitions="abl,aop,bluetooth,cmnlib,cmnlib64,devcfg,dsp,featenabler,hyp,imagefv,keymaster,modem,qupfw,tz,uefisecapp,xbl,xbl_config"

for i in $zips; do
    echo "Downloading $(basename "$i").."
    aria2c --file-allocation=none -x 16 "$i"
    echo "Extracting firmware from $(basename "$i")..."
    ./payload-dumper-go -p "$partitions" -o . "$(basename "$i")" >/dev/null 2>&1
    echo "Zipping firmware_$(basename "$i")..."
    zip -r -q firmware_"$(basename "$i")" META-INF *.img flash_firmware* && rm *.img
    rm "$(basename "$i")"
done

echo "Firmware extraction completed."
