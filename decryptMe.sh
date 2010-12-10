#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# encryptMe.sh
# =
# 2010, Hewlett-Packard Company
# Andres Aquino <aquino@hp.com>
# All rights reserved.
# 

. ${HOME}/.shelltemplaterc

# encrypted file
encryptedFile="${1}"

echo "Decrypting file..."
info=`openssl enc -d -aes256 -salt -pass file:${AP_KEYF} -in ${encryptedFile}`

# show information
echo " param[user]: ${info%@*}"
echo " param[pswd]: ${info#*@}"


# 
