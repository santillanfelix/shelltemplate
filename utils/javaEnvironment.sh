#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai syntax=sh: 

# javaEnvironment.sh
# =
#
# Andres Aquino <aquino(at)hp.com>
# Hewlett-Packard Company | EBS
# 

# load additional funcions
. ${APPATH}/utils/libUtils.sh

javaEnvironment ()
{
  # Language
  LANG=es_MX.iso88591

  # java's environment
  JAVA_FLAGS=

  # Initial and Maximum size of the Java Heap
  JAVA_FLAGS="${JAVA_FLAGS} -Xms512m"
  JAVA_FLAGS="${JAVA_FLAGS} -Xmx512m"

  # Size of the heap reserved for the permanent generation hold
  JAVA_FLAGS="${JAVA_FLAGS} -XX:PermSize=64m"
  JAVA_FLAGS="${JAVA_FLAGS} -XX:MaxPermSize=128m"

  # HeapDump
  JAVA_FLAGS="${JAVA_FLAGS} -XX:+HeapDumpOnCtrlBreak"
  JAVA_FLAGS="${JAVA_FLAGS} -XX:HeapDumpPath=${APPATH}/logs/${APNAME}-${APTIME}.hprof"

  # Garbage Collector
  JAVA_FLAGS="${JAVA_FLAGS} -XX:+DisableExplicitGC"
  JAVA_FLAGS="${JAVA_FLAGS} -XX:file=${APHOME}/logs/${APNAME}-${APTIME}.gc"

  # Java Security Policy
  JAVA_FLAGS="${JAVA_FLAGS} -Djava.security.policy=${APHOME}/java.policy"

}

javaClasspath ()
{
  # Java Classes
  JAVA_CLASSPATH="."
  for classfile in "${APHOME}/libs/*.jar"
  do
    JAVA_CLASSPATH="${classfile}:${JAVA_CLASSPATH}"
  done

  export CLASSPATH="${JAVA_CLASSPATH}:."

}

java16 () {
  [ -d /opt/java-1.6.0-sun ] && export JAVA_HOME=/opt/java-1.6.0-sun
  [ -d /opt/java/java1.6 ] && export JAVA_HOME=/opt/java/java1.6
  [ -d /opt/java/java6 ] && export JAVA_HOME=/opt/java/java6
  PATH=${JAVA_HOME}/bin:${PATH}
  JAVA_VER=`java -version 2>&1 | grep "version" | sed -e "s/\"//g"`
}

java15 () {
  [ -d /opt/java-1.5.0-sun ] && export JAVA_HOME=/opt/java-1.5.0-sun
  [ -d /opt/java/java1.5 ] && export JAVA_HOME=/opt/java/java1.5
  PATH=${JAVA_HOME}/bin:${PATH}
  JAVA_VER=`java -version 2>&1 | grep "version" | sed -e "s/\"//g"`
}

java14 () {
  [ -d /opt/java/java1.4 ] && export JAVA_HOME=/opt/java/java1.4
  PATH=${JAVA_HOME}/bin:${PATH}
  JAVA_VER=`java -version 2>&1 | grep "version" | sed -e "s/\"//g"`
}

#
