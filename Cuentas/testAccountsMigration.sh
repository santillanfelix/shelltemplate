#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# testAccountsMigration.sh
# =
#

. ${HOME}/.costcontrolrc

TS=`date +%s`
getUserInformation "user-cost.pswd"
echo "User: ${user}"
echo "Pasw: ${pasw}"

