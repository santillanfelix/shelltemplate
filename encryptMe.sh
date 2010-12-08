#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# encryptMe.sh
# =
# 2010, Hewlett-Packard Company
# Andres Aquino <aquino@hp.com>
# All rights reserved.
# 

fpass="${1}"
fcyphred="${1%.info}.pswd"

echo "Encrypting file..."
openssl enc -aes256 -salt -pass file:CostControl.key -in ${fpass} -out ${fcyphred}
mv ${fpass} .${fpass}


# 
