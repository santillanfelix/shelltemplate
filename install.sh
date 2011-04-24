#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 si ai et: 

# install.sh 
# =
#
# Andres Aquino <aquino(at)hp.com>
# Hewlett-Packard Company
# 

echo "[1] - Creating structure..."
mkdir -p ~/bin
mkdir -p ~/manuals/man1

echo "[2] - Migrating all config files to new version..."
cd ~/ShellTemplate.git/conf/
[ -d ~/ShellT ] && cp -rp ~/ShellTemplate/conf/*.conf .
for ap in *.conf
do
  ln -sf ../soya.sh ${ap%.conf}.start
done

echo "[3] - Switching to new version..."
cd ~
[ -d ~/soya.old ] && rm -fr ~/soya.old
[ -d ~/soya ] && mv ~/soya ~/soya.old
[ -d ~/soya.git ] && mv ~/soya.git ~/soya

echo "[4] - Installing unix documentation..."
cp ~/soya/man1/soya.1 ~/manuals/man1/
ln -sf ~/soya/soya.sh ~/soya/soya.version
ln -sf ~/soya/soyarc ~/.soyarc
ln -sf ~/soya/screenrc ~/.screenrc

echo "[5] - Fixing permissiont..."
chmod 0640 ~/soya/install.sh 
chmod 0550 ~/soya/soya.sh

echo "[*] - That's all..."
#
# get current directory
CURRENT=`dirname ${0}`
if [ ${CURRENT} == "." ]
then
  echo "please, move to application's directory"
  exit 1
fi

# create RC file
[ -h ${HOME}/.shelltemplaterc ] && rm -f ${HOME}/.shelltemplaterc
ln -sf ${CURRENT}/setEnvironment.rc ${HOME}/.shelltemplaterc 

#
