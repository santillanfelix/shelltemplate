#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# svcbatchcci.sh
# =
#

. ${HOME}/nextel.profile
. ${HOME}/svcbatchcci.rc
. ${AP_HOME}/utils/libutils.sh

java16
java -version
set_java_environment
set_java_classpath

java ${JAVA_FLAGS} -cp ${JAVA_CLASSPATH} com.nextel.mx.batch.rmi.CompBatchServer

TS=`date +%s`
getUserInformation "infoApp.pswd"
echo "User: ${user}"
echo "Pasw: ${pasw}"

