#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# testApplication.sh
# =
#

. ${HOME}/.shelltemplaterc

TS=`date +%s`
getUserInformation "infoApp.pswd"
echo "User: ${user}"
echo "Pasw: ${pasw}"

