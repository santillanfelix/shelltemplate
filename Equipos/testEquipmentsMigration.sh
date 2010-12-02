#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# testEquipmentsMigration.sh
# =
#

. ${HOME}/.costcontrolrc

TS=`date +%s`
getUserInformation "user-siscob.pswd"
echo "User: ${user}"
echo "Pasw: ${pasw}"

