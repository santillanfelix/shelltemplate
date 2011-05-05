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
  ln -sf ../shelltemplate.sh ${ap%.conf}.start
done

echo "[3] - Switching to new version..."
cd ~
[ -d ~/shelltemplate.old ] && rm -fr ~/shelltemplate.old
[ -d ~/shelltemplate ] && mv ~/shelltemplate ~/shelltemplate.old
[ -d ~/shelltemplate.git ] && mv ~/shelltemplate.git ~/shelltemplate

echo "[4] - Installing unix documentation..."
cp ~/shelltemplate/man1/shelltemplate.1 ~/manuals/man1/
ln -sf ~/shelltemplate/shelltemplate.sh ~/shelltemplate/shelltemplate.version
ln -sf ~/shelltemplate/shelltemplaterc ~/.shelltemplaterc
ln -sf ~/shelltemplate/screenrc ~/.screenrc

echo "[5] - Fixing permissiont..."
chmod 0640 ~/shelltemplate/install.sh 
chmod 0550 ~/shelltemplate/shelltemplate.sh

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
