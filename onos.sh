#!/bin/bash

echo "###########################"
echo "#ONOS 1.14.0 INSTALL START#"
echo "###########################"

echo "ADD USER SDN"
if [ `id -u sdn 2>/dev/null || echo -1` -ge 0 ]
then
	echo "user sdn is exist"
else
	sudo adduser sdn --system --group
	echo "user sdn added"
fi

echo "INSTALL OPENJDK 8"
if which java
then
	echo "openjdk is installed"
else
	sudo apt update
	sudo apt install openjdk-8-jdk -y
	java -version
fi

echo "MKDIR /OPT"
if [ -d /opt ]
then
	echo "/opt directory exist"
	cd /opt
else
	sudo mkdir -p /opt && cd /opt
fi

echo "DOWNLOAD ONOS"
if [ -f onos-1.14.0.tar.gz ]
then
	echo "onos 1.14.0 exist"
else
	sudo wget https://repo1.maven.org/maven2/org/onosproject/onos-releases/1.14.0/onos-1.14.0.tar.gz
	sudo tar xzf onos-1.14.0.tar.gz
	sudo mv onos-1.14.0 onos
	sudo chown -R sdn:sdn onos
fi

echo "SETTING ONOS STARTUP OPTIONS"
touch /opt/onos/options
export ONOS_USER=sdn >> /opt/onos/options
export ONOS_APPS=drivers,openflow,fwd >> /opt/onos/options
sudo chown sdn /opt/onos/options

echo "START ONOS AS A SERVICE"
sudo cp /opt/onos/init/onos.initd /etc/init.d/onos
sudo cp /opt/onos/init/onos.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable onos
sudo systemctl start onos

echo "################"
echo "#HAPPY ONOS-ing#"
echo "################"
