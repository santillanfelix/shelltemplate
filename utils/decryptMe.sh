#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# encryptMe.sh
# =
#
# Andres Aquino <aquino@hp.com>
# Hewlett-Packard Company
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
