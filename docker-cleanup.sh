#!/bin/bash
apt-get -y autoremove
apt-get clean
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
##rm -f /etc/ssh/ssh_host_*
rm -rf /usr/share/man/??
rm -rf /usr/share/man/??_*
