#/bin/bash

curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
apt update

apt-get -y install gcc cmake libglib2.0-dev libgnutls28-dev libpq-dev postgresql-server-dev-11 pkg-config libical-dev xsltproc libgpgme-dev
