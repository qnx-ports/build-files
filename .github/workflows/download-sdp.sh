#!/bin/bash

echo "Downloading QNX Software Center ..."
mkdir $WORKSPACE/.qnx
curl -v --cookie-jar /.qnx/myqnxcookies.auth --form "userlogin=$MYQNX_USER" --form "password=$MYQNX_PASSWORD" -X POST https://www.qnx.com/account/login.html > login_response.html
curl -v -L --cookie $WORKSPACE/.qnx/myqnxcookies.auth https://www.qnx.com/download/download/77351/qnx-setup-2.0.3-202408131717-linux.run > qnx-setup-lin.run
chmod a+x qnx-setup-lin.run
./qnx-setup-lin.run force-override disable-auto-start agree-to-license-terms $WORKSPACE/qnxinstall

echo "Installing License ..."
$WORKSPACE/qnxinstall/qnxsoftwarecenter/qnxsoftwarecenter_clt -syncLicenseKeys -myqnx.user="$MYQNX_USER" -myqnx.password="$MYQNX_PASSWORD" -addLicenseKey $LICENSE_KEY
cp -r ~/.qnx/license $WORKSPACE/.qnx

echo "Downloading QNX SDP ..."
$WORKSPACE/qnxinstall/qnxsoftwarecenter/qnxsoftwarecenter_clt -mirror -cleanInstall -destination $WORKSPACE/qnx800 -installBaseline com.qnx.qnx800 -myqnx.user="$MYQNX_USER" -myqnx.password="$MYQNX_PASSWORD"
