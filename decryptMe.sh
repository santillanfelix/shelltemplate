#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# encryptMe.sh
# =
# 2010, Hewlett-Packard Company
# Andres Aquino <aquino@hp.com>
# All rights reserved.
# 

. ${HOME}/.shelltemplaterc

fcyphred="${1}"

echo "Decrypting file..."
info=`openssl enc -d -aes256 -salt -pass file:CostControl.key -in ${fcyphred}`
echo " > parameter[1]: ${info%@*}"
echo " > parameter[2]: ${info#*@}"


# 
