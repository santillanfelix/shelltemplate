#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# encryptMe.sh
# =
# 2010, Hewlett-Packard Company
# Andres Aquino <aquino@hp.com>
# All rights reserved.
# 

. ${HOME}/.shelltemplaterc

# unencrypted file & encrypted file
unencryptedFile="${1}"
encryptedFile="${1%.info}.pswd"

echo "Encrypting file..."
openssl enc -aes256 -salt -pass file:${AP_KEYF} -in ${unencryptedFile} -out ${encryptedFile}

# save (temporaly)
mv ${unencryptedFile} .${unencryptedFile}


# 
