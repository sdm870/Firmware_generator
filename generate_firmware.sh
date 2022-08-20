#!/bin/bash

set -e

arch=$(arch)
if [ $arch == x86_64 ]; then
    arch=amd64
fi

payload_link="https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_linux_$arch.tar.gz"
wget $payload_link -O payload-dumper-go.tar.gz
tar -xf payload-dumper-go.tar.gz payload-dumper-go && rm payload-dumper-go.tar.gz

partitions="abl,aop,bluetooth,cmnlib,cmnlib64,devcfg,dsp,featenabler,hyp,imagefv,keymaster,modem,qupfw,tz,uefisecapp,xbl,xbl_config"

wget -O $(basename $1) $1
./payload-dumper-go -p $partitions -o . $(basename $1)
zip -r firmware_$(basename $1) META-INF *.img flash_firmware* && rm *.img
rm $(basename $1)
