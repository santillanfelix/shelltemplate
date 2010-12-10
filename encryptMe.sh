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
uncryptedFile="${1}"
encryptedFile="${1%.info}.pswd"

echo "Encrypting file..."
openssl enc -aes256 -salt -pass file:${APP_KEYF} -in ${uncryptedFile} -out ${encryptedFile}

# save (temporaly)
mv ${uncryptedFile} .${uncryptedFile}


# 
