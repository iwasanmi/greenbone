#/bin/bash


#Configure PostgreSQL database
sudo -u postgres bash
createuser -DRS gvm && createdb -O gvm gvmd
psql gvmd


#Setup correct permissions and create database extensions.
create role dba with superuser noinherit;
grant dba to gvm;
create extension "uuid-ossp";
create extension "pgcrypto";
exit

