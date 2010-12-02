#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 si ai et: 

# install.sh 
# =
# 2010, Hewlett-Packard Company
# Andres Aquino <aquino@hp.com>
# All rights reserved.
# 

# get current directory
CURRENT=`dirname ${0}`
if [ ${CURRENT} == "." ]
then
  echo "please, move to application's directory"
  exit 1
fi

# create RC file
[ -h ${HOME}/.costcontrolrc ] && rm -f ${HOME}/.costcontrolrc
ln -sf ${CURRENT}/CostControl.rc ${HOME}/.costcontrolrc 

#
