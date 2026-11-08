#!/usr/bin/env bash
# Install MySQL Community Server 8.4 LTS on Ubuntu 24.04 from Oracle's MySQL APT repository.
# Usage: sudo bash install-mysql-8.4.sh
set -euo pipefail

APT_CONFIG_DEB=mysql-apt-config_0.8.36-1_all.deb

apt-get update
apt-get install -y wget lsb-release gnupg

# 1. Add Oracle's repository. The package asks which series to enable;
#    we pre-answer "mysql-8.4-lts" so the dialog does not appear.
wget -q "https://repo.mysql.com/${APT_CONFIG_DEB}"
echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.4-lts" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg -i "${APT_CONFIG_DEB}"
rm -f "${APT_CONFIG_DEB}"

# 2. Install the server (plus client tools) from that repository.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

# 3. Supporting tools used throughout the course.
apt-get install -y git curl

mysql --version
