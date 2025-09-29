#!/bin/bash

adduser $1
usermod -aG users $1
usermod -aG dovecot $1

mkdir -p /home/$1/Maildir/cur
mkdir -p /home/$1/Maildir/new
mkdir -p /home/$1/Maildir/tmp

chown -R $1:$1 /home/$1
