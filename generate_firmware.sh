#!/bin/bash

set -e

arch=$(arch)
if [ $arch == x86_64 ]; then
    arch=amd64
fi

payload_link="https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_linux_$arch.tar.gz"
zips="https://bigota.d.miui.com/V13.0.6.0.SKHINXM/miui_ALIOTHINGlobal_V13.0.6.0.SKHINXM_2492066c1d_12.0.zip
      https://bigota.d.miui.com/V13.0.6.0.SKHEUXM/miui_ALIOTHEEAGlobal_V13.0.6.0.SKHEUXM_c393876947_12.0.zip
      https://bigota.d.miui.com/V13.0.3.0.SKHMIXM/miui_ALIOTHGlobal_V13.0.3.0.SKHMIXM_07afcb74cd_12.0.zip
      https://bigota.d.miui.com/V13.0.2.0.SKHIDXM/miui_ALIOTHIDGlobal_V13.0.2.0.SKHIDXM_80a5a01aa6_12.0.zip
      https://bigota.d.miui.com/V13.0.2.0.SKHRUXM/miui_ALIOTHRUGlobal_V13.0.2.0.SKHRUXM_101e499a8e_12.0.zip
      https://bigota.d.miui.com/V13.0.1.0.SKHTWXM/miui_ALIOTHTWGlobal_V13.0.1.0.SKHTWXM_1573a396df_12.0.zip
      https://bigota.d.miui.com/V13.0.1.0.SKHTRXM/miui_ALIOTHTRGlobal_V13.0.1.0.SKHTRXM_1eaf50fc2f_12.0.zip
      https://bigota.d.miui.com/V13.0.5.0.SKHCNXM/miui_ALIOTH_V13.0.5.0.SKHCNXM_540c833165_12.0.zip"

wget $payload_link -O payload-dumper-go.tar.gz
tar -xf payload-dumper-go.tar.gz payload-dumper-go && rm payload-dumper-go.tar.gz

partitions="abl,aop,bluetooth,cmnlib,cmnlib64,devcfg,dsp,featenabler,hyp,imagefv,keymaster,modem,qupfw,tz,uefisecapp,xbl,xbl_config"

for i in $zips
do
    wget -O $(basename $i) $i
    ./payload-dumper-go -p $partitions -o . $(basename $i)
    zip -r firmware_$(basename $i) META-INF *.img flash_firmware* && rm *.img
    rm $(basename $1)
done
