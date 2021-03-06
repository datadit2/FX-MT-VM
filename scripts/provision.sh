#!/bin/sh -e

#
# Provisioning script
#

# Initialize script.
if [ ! -d "/vagrant" ] && [ ! -d "/home/travis" ]; then
  echo "This script needs to be run within VM."
  exit 1
fi
whoami && pwd
type dpkg apt-get git

# Init variables.
ARCH=$(dpkg --print-architecture)
id travis  && USER="travis"
id vagrant && USER="vagrant"

# Perform an unattended installation of a Debian packages.
export DEBIAN_FRONTEND=noninteractive
ex +"%s@DPkg@//DPkg" -scwq /etc/apt/apt.conf.d/70debconf
dpkg-reconfigure debconf -f noninteractive

# Install the language pack to prevent an invalid locale.
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
apt-get install -y language-pack-en

# Install basic utils.
apt-get install -y coreutils realpath links html2text tree

# Install and run X virtual framebuffer and X utils.
apt-get install -y xvfb xdotool

# Install wine
dpkg --add-architecture i386 || true
add-apt-repository -y ppa:ubuntu-wine/ppa
find /etc/apt/sources.list.d -type f -name '*.list' -exec apt-get update -o Dir::Etc::sourcelist="{}" ';'
apt-get -d update
apt-get install -y wine1.7 winetricks

# Run X virtual framebuffer on screen 0.
export DISPLAY=:0
Xvfb $DISPLAY -screen 0 1024x768x16 & # Run X virtual framebuffer on screen 0.

# Set-up git.
git config --system user.name $USER
git config --system user.email "$USER@$HOSTNAME"
git config --system core.sharedRepository group

# Add version control for /opt.
git init /opt

# Give user write permission for /opt.
chown -R $USER /opt

echo "$0 done."
