#/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y libopenvas-dev
sudo apt-get install -y build-essential 
sudo apt-get install -y cmake pkg-config glib2.0 gcc-mingw-w64 \
gnutls-bin libgnutls28-dev libxml2-dev libssh-dev libssl-dev libunistring-dev \
libldap2-dev libgcrypt-dev libpcap-dev libgpgme-dev libradcli-dev \
libksba-dev libical-dev libpq-dev libopenvas-dev libpopt-dev libnet1-dev \
libmicrohttpd-dev redis-server libhiredis-dev doxygen xsltproc \
graphviz bison postgresql postgresql-contrib postgresql-server-dev-all \

heimdal-dev xmltoman nmap npm nodejs virtualenv \
python3-paramiko python3-lxml python3-defusedxml python3-pip python3-psutil \
xmlstarlet texlive-fonts-recommended texlive-latex-extra


#install yarn using npm
sudo npm install -g yarn --prefix /usr/

#user instalation path
server@ubuntu:~$ sudo useradd -r -M -U -G sudo -s /usr/sbin/nologin gvm && \
sudo usermod -aG gvm $USER && su $USER

#Next define base, source, build and installation directories.
export PATH=$PATH:/usr/local/sbin && export INSTALL_PREFIX=/usr/local && \
export SOURCE_DIR=$HOME/source && mkdir -p $SOURCE_DIR && \
export BUILD_DIR=$HOME/build && mkdir -p $BUILD_DIR && \
export INSTALL_DIR=$HOME/install && mkdir -p $INSTALL_DIR


#Download the signing key from Greenbone community to validate the integrity of the source files.
curl -O https://www.greenbone.net/GBCommunitySigningKey.asc && \
gpg --import GBCommunitySigningKey.asc

#Edit GVM signing key to trust ultimately
gpg --edit-key 9823FAA60ED1E580

#Download and build the GVM libraries version 21.04 (21.4.2). Set the GVM libraries to same version as GVM.
export GVM_VERSION=21.4.2 && \
export GVM_LIBS_VERSION=$GVM_VERSION

#Download and verify the specified GVM libraries.
curl -f -L https://github.com/greenbone/gvm-libs/archive/refs/tags/v$GVM_LIBS_VERSION.tar.gz -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz && \
curl -f -L https://github.com/greenbone/gvm-libs/releases/download/v$GVM_LIBS_VERSION/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc && \
gpg --verify $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz


#Once you've confirmed that the signature is good proceed to install GVM libraries.
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz && \
mkdir -p $BUILD_DIR/gvm-libs && cd $BUILD_DIR/gvm-libs && \
cmake $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var \
  -DGVM_PID_DIR=/run/gvm && \
make DESTDIR=$INSTALL_DIR install && \
sudo cp -rv $INSTALL_DIR/* / && \
rm -rf $INSTALL_DIR/*


#Next download, verify and build the Greenbone Vulnerability Manager (GVM) version 21.04 (21.4.3). Set the GVMD version to the latest realese 21.4.3.
export GVMD_VERSION=21.4.3 && \
curl -f -L https://github.com/greenbone/gvmd/archive/refs/tags/v$GVMD_VERSION.tar.gz -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz && \
curl -f -L https://github.com/greenbone/gvmd/releases/download/v$GVMD_VERSION/gvmd-$GVMD_VERSION.tar.gz.asc -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc && \
gpg --verify $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz


#Extract the downloaded GVMD file and proceed with the installation.
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz && \
mkdir -p $BUILD_DIR/gvmd && cd $BUILD_DIR/gvmd && \
cmake $SOURCE_DIR/gvmd-$GVMD_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLOCALSTATEDIR=/var \
  -DSYSCONFDIR=/etc \
  -DGVM_DATA_DIR=/var \
  -DGVM_RUN_DIR=/run/gvm \
  -DOPENVAS_DEFAULT_SOCKET=/run/ospd/ospd-openvas.sock \
  -DGVM_FEED_LOCK_PATH=/var/lib/gvm/feed-update.lock \
  -DSYSTEMD_SERVICE_DIR=/lib/systemd/system \
  -DDEFAULT_CONFIG_DIR=/etc/default \
  -DLOGROTATE_DIR=/etc/logrotate.d && \
make DESTDIR=$INSTALL_DIR install && \
sudo cp -rv $INSTALL_DIR/* / && \
rm -rf $INSTALL_DIR/*

#Proceed to download and build the Greenbone Security Assistant (GSA) version 21.04 (21.4.2) and its node modules.
export GSA_VERSION=$GVM_VERSION && \
curl -f -L https://github.com/greenbone/gsa/archive/refs/tags/v$GSA_VERSION.tar.gz -o $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz && \
curl -f -L https://github.com/greenbone/gsa/releases/download/v$GSA_VERSION/gsa-$GSA_VERSION.tar.gz.asc -o $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz.asc && \
curl -f -L https://github.com/greenbone/gsa/releases/download/v$GSA_VERSION/gsa-node-modules-$GSA_VERSION.tar.gz -o $SOURCE_DIR/gsa-node-modules-$GSA_VERSION.tar.gz && \
curl -f -L https://github.com/greenbone/gsa/releases/download/v$GSA_VERSION/gsa-node-modules-$GSA_VERSION.tar.gz.asc -o $SOURCE_DIR/gsa-node-modules-$GSA_VERSION.tar.gz.asc && \
gpg --verify $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz.asc $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz && \
gpg --verify $SOURCE_DIR/gsa-node-modules-$GSA_VERSION.tar.gz.asc $SOURCE_DIR/gsa-node-modules-$GSA_VERSION.tar.gz

#Proceed with the installation of GSA.
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz && \
tar -C $SOURCE_DIR/gsa-$GSA_VERSION/gsa -xvzf $SOURCE_DIR/gsa-node-modules-$GSA_VERSION.tar.gz && \
mkdir -p $BUILD_DIR/gsa && cd $BUILD_DIR/gsa && \
cmake $SOURCE_DIR/gsa-$GSA_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var \
  -DGVM_RUN_DIR=/run/gvm \
  -DGSAD_PID_DIR=/run/gvm \
  -DLOGROTATE_DIR=/etc/logrotate.d && \
make DESTDIR=$INSTALL_DIR install && \
sudo cp -rv $INSTALL_DIR/* / && \
rm -rf $INSTALL_DIR/*

#Download and build the OpenVAS SMB module version 21.04.
export OPENVAS_SMB_VERSION=21.4.0 && \
curl -f -L https://github.com/greenbone/openvas-smb/archive/refs/tags/v$OPENVAS_SMB_VERSION.tar.gz -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz && \
curl -f -L https://github.com/greenbone/openvas-smb/releases/download/v$OPENVAS_SMB_VERSION/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc && \
gpg --verify $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz

#Next extract files and proceed with the installation.
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz && \
mkdir -p $BUILD_DIR/openvas-smb && cd $BUILD_DIR/openvas-smb && \
cmake $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release && \
make DESTDIR=$INSTALL_DIR install && \
sudo cp -rv $INSTALL_DIR/* / && \
rm -rf $INSTALL_DIR/

#Download and build the openvas-scanner (OpenVAS) version 21.04 (21.4.1).
export OPENVAS_SCANNER_VERSION=$GVM_VERSION && \
curl -f -L https://github.com/greenbone/openvas-scanner/archive/refs/tags/v$OPENVAS_SCANNER_VERSION.tar.gz -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz && \
curl -f -L https://github.com/greenbone/openvas-scanner/releases/download/v$OPENVAS_SCANNER_VERSION/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc && \
gpg --verify $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz

#
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz && \
mkdir -p $BUILD_DIR/openvas-scanner && cd $BUILD_DIR/openvas-scanner && \
cmake $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var \
  -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
  -DOPENVAS_RUN_DIR=/run/ospd && \
make DESTDIR=$INSTALL_DIR install && \
sudo cp -rv $INSTALL_DIR/* / && \
rm -rf $INSTALL_DIR/*


#Build ospd and ospd-openvas
export OSPD_VERSION=21.4.3 && export OSPD_OPENVAS_VERSION=$GVM_VERSION && \
curl -f -L https://github.com/greenbone/ospd/archive/refs/tags/v$OSPD_VERSION.tar.gz -o $SOURCE_DIR/ospd-$OSPD_VERSION.tar.gz && \
curl -f -L https://github.com/greenbone/ospd/releases/download/v$OSPD_VERSION/ospd-$OSPD_VERSION.tar.gz.asc -o $SOURCE_DIR/ospd-$OSPD_VERSION.tar.gz.asc && \
curl -f -L https://github.com/greenbone/ospd-openvas/archive/refs/tags/v$OSPD_OPENVAS_VERSION.tar.gz -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz && \
curl -f -L https://github.com/greenbone/ospd-openvas/releases/download/v$OSPD_OPENVAS_VERSION/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc && \
gpg --verify $SOURCE_DIR/ospd-$OSPD_VERSION.tar.gz.asc $SOURCE_DIR/ospd-$OSPD_VERSION.tar.gz && \
gpg --verify $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz


#Extract files and start the installation.
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/ospd-$OSPD_VERSION.tar.gz && \
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz && \
cd $SOURCE_DIR/ospd-$OSPD_VERSION && \
python3 -m pip install . --prefix=$INSTALL_PREFIX --root=$INSTALL_DIR

#Before you're done upgrade python3-psutil to version 5.7.2 then proceed to finialize the installation of ospd-openvas and install gvm-tools.
pip install --upgrade psutil==5.7.2 && \
cd $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION && \
python3 -m pip install . --prefix=$INSTALL_PREFIX --root=$INSTALL_DIR --no-warn-script-location && \
python3 -m pip install --user gvm-tools && \
sudo cp -rv $INSTALL_DIR/* / && \
rm -rf $INSTALL_DIR/*

#Next configure redis for the default GVM installation.
sudo cp $SOURCE_DIR/openvas-scanner-$GVM_VERSION/config/redis-openvas.conf /etc/redis/ && \
sudo chown redis:redis /etc/redis/redis-openvas.conf && \
echo "db_address = /run/redis-openvas/redis.sock" | sudo tee -a /etc/openvas/openvas.conf

#Start the redis server and enable it as an start up service.
sudo systemctl start redis-server@openvas.service && \
sudo systemctl enable redis-server@openvas.service

#Add redis to the GVM group and set up correct permissions.
sudo usermod -aG redis gvm && \
sudo chown -R gvm:gvm /var/lib/gvm && \
sudo chown -R gvm:gvm /var/lib/openvas && \
sudo chown -R gvm:gvm /var/log/gvm && \
sudo chown -R gvm:gvm /run/gvm && \
sudo chmod -R g+srw /var/lib/gvm && \
sudo chmod -R g+srw /var/lib/openvas && \
sudo chmod -R g+srw /var/log/gvm && \
sudo chown gvm:gvm /usr/local/sbin/gvmd && \
sudo chmod 6750 /usr/local/sbin/gvmd

#You also need to adjust the permissions for the feed synchronization.
sudo chown gvm:gvm /usr/local/bin/greenbone-nvt-sync && \
sudo chmod 740 /usr/local/sbin/greenbone-feed-sync && \
sudo chown gvm:gvm /usr/local/sbin/greenbone-*-sync && \
sudo chmod 740 /usr/local/sbin/greenbone-*-sync

#OpenVAS will be launched from an ospd-openvas process. Update the secure path in the sudoers file accordingly.

