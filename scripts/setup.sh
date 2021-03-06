#!/bin/sh

#-------------------------------------------------------------------
#
# This file is part of the CernVM File System.
#
#-------------------------------------------------------------------

set -e

SCRIPT_LOCATION=$(cd "$(dirname "$0")"; pwd)

# Setup Mnesia
echo "Setting up the Mnesia"

cvmfs_mnesia_root=/opt/cvmfs-mnesia
echo "  - (re)creating schema directory at $cvmfs_mnesia_root"
sudo rm -rf $cvmfs_mnesia_root && sudo mkdir -p $cvmfs_mnesia_root

echo "  - creating Mnesia schema"
sudo $SCRIPT_LOCATION/../bin/cvmfs_gateway escript scripts/setup_mnesia.escript $cvmfs_mnesia_root

# Install syslog configuration file
echo "Installing the syslog configuration file"
sudo cp -v $SCRIPT_LOCATION/90-cvmfs-gateway.conf /etc/rsyslog.d/

# Symlink the configuration directory into /etc/cvmfs/gateway
if [ ! -e /etc/cvmfs/gateway ]; then
    echo "Creating onfiguration file directory to /etc/cvmfs/gateway"
    sudo mkdir /etc/cvmfs/gateway
    sudo cp -v $SCRIPT_LOCATION/../etc/*.json /etc/cvmfs/gateway/
fi

if [ x"$(which systemctl)" != x"" ]; then
    echo "  - restarting rsyslog"
    sudo systemctl restart rsyslog
    sudo cp -v $SCRIPT_LOCATION/90-cvmfs-gateway-rotate-systemd /etc/logrotate.d/

    echo "  - installing systemd service file"
    sudo cp -v $SCRIPT_LOCATION/cvmfs-gateway.service /etc/systemd/system/cvmfs-gateway.service
else
    echo "  - restarting rsyslog"
    sudo service rsyslog restart
    sudo cp -v $SCRIPT_LOCATION/90-cvmfs-gateway-rotate /etc/logrotate.d/
fi

