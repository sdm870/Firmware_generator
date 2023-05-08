#!/bin/bash

set -e

arch=$(arch)
if [ $arch == x86_64 ]; then
    arch=amd64
fi

if [ $arch == aarch64 ]; then
    arch=arm64
fi

payload_link="https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_linux_$arch.tar.gz"
zips="https://bigota.d.miui.com/V14.0.3.0.TKHINXM/miui_ALIOTHINGlobal_V14.0.3.0.TKHINXM_d2d6e90e6d_13.0.zip
      https://bigota.d.miui.com/V14.0.7.0.TKHEUXM/miui_ALIOTHEEAGlobal_V14.0.7.0.TKHEUXM_4f54362c0d_13.0.zip
      https://bigota.d.miui.com/V14.0.4.0.TKHMIXM/miui_ALIOTHGlobal_V14.0.4.0.TKHMIXM_b9ed940850_13.0.zip
      https://bigota.d.miui.com/V14.0.2.0.TKHIDXM/miui_ALIOTHIDGlobal_V14.0.2.0.TKHIDXM_171dfd6f1e_13.0.zip
      https://bigota.d.miui.com/V14.0.1.0.TKHRUXM/miui_ALIOTHRUGlobal_V14.0.1.0.TKHRUXM_310b547162_13.0.zip
      https://bigota.d.miui.com/V14.0.1.0.TKHTWXM/miui_ALIOTHTWGlobal_V14.0.1.0.TKHTWXM_66bf484519_13.0.zip
      https://bigota.d.miui.com/V14.0.1.0.TKHTRXM/miui_ALIOTHTRGlobal_V14.0.1.0.TKHTRXM_69e8dd9865_13.0.zip
      https://bigota.d.miui.com/V14.0.6.0.TKHCNXM/miui_ALIOTH_V14.0.6.0.TKHCNXM_7b7bb4a7bc_13.0.zip"

echo "Downloading payload dumper..."
wget --quiet $payload_link -O payload-dumper-go.tar.gz
tar -xf payload-dumper-go.tar.gz payload-dumper-go && rm payload-dumper-go.tar.gz

partitions="abl,aop,bluetooth,cmnlib,cmnlib64,devcfg,dsp,featenabler,hyp,imagefv,keymaster,modem,qupfw,tz,uefisecapp,xbl,xbl_config"

for i in $zips
do
    echo "Downloading $(basename $i).."
    wget --quiet -O $(basename $i) $i
    ./payload-dumper-go -p $partitions -o . $(basename $i) >/dev/null 2>&1
    echo "Zipping firmware_$(basename $i)..."
    zip -r -q firmware_$(basename $i) META-INF *.img flash_firmware* && rm *.img
    rm $(basename $i)
done
