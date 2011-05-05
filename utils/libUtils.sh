#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 si ai et: 

# libutils.sh 
# =
#
# Andres Aquino <aquino(at)hp.com>
# Hewlett-Packard Company | EBS
# 

#
# constants
# initialize app enviroment
APSYSO="`uname -s`"
APHOST=`hostname | sed -e "s/\..*//g"`
APUSER=`id -u -n`
APDATE=`date "+%Y%m%d"`
APHOUR=`date "+%H%M"`
APTIME="${APDATE}${APHOUR}"
APLEVL="DEBUG"

# globals
export APLOGS=
export APLOGP=
export APLOGT=
export APPRCS=
APFLTR=

# Eye candy
CLTYPE="\e"
[ "${APSYSO}" = "HP-UX" ] && CLTYPE="\033"

#
# get the enviroment for the SO running
setEnvironment () {
  # terminal line settings
  stty 2> /dev/null > /dev/null 

  if [ "$?" = "0" ]
  then
    # terminal line settings
    stty erase '^?'
    stty intr '^C' 
    stty kill '^U' 
    stty stop '^S'
    stty susp '^Z'
    stty werase '^W'

    # command line _eye candy_
    CRESET="${CLTYPE}[0m"    # Text Reset
    TXTBLK="${CLTYPE}[0;30m" # Black - Regular
    TXTRED="${CLTYPE}[0;31m" # Red
    TXTGRN="${CLTYPE}[0;32m" # Green
    TXTYLW="${CLTYPE}[0;33m" # Yellow
    TXTBLU="${CLTYPE}[0;34m" # Blue
    TXTPUR="${CLTYPE}[0;35m" # Purple
    TXTCYN="${CLTYPE}[0;36m" # Cyan
    TXTWHT="${CLTYPE}[0;37m" # White
    BLDBLK="${CLTYPE}[1;30m" # Black - Bold
    BLDRED="${CLTYPE}[1;31m" # Red
    BLDGRN="${CLTYPE}[1;32m" # Green
    BLDYLW="${CLTYPE}[1;33m" # Yellow
    BLDBLU="${CLTYPE}[1;34m" # Blue
    BLDPUR="${CLTYPE}[1;35m" # Purple
    BLDCYN="${CLTYPE}[1;36m" # Cyan
    BLDWHT="${CLTYPE}[1;37m" # White
 
  else
    # command line _eye candy_
    CRESET="${CLTYPE}[0m"    # Text Reset
    TXTBLK="${CLTYPE}[0;30m" # Black - Regular
    TXTRED="" # Red
    TXTGRN="" # Green
    TXTYLW="" # Yellow
    TXTBLU="" # Blue
    TXTPUR="" # Purple
    TXTCYN="" # Cyan
    TXTWHT="${CLTYPE}[0;37m" # White
    BLDBLK="${CLTYPE}[1;30m" # Black - Bold
    BLDRED="" # Red
    BLDGRN="" # Green
    BLDYLW="" # Yellow
    BLDBLU="" # Blue
    BLDPUR="" # Purple
    BLDCYN="" # Cyan
    BLDWHT="${CLTYPE}[1;37m" # White
 
  fi
  
  # applications's name
  if [ ${#APNAME} -eq 0 ]
  then
    APNAME="`basename ${0}`"
    APNAME="${APNAME%.*}"
  fi

  # application's path
  if [ ${#APPATH} -eq 0 ]
  then
    APPATH=${APHOME}/${APNAME}
  fi
  [ ! -d ${APPATH} ] && mkdir -p ${APPATH}
  [ -s ${APPATH}/PROFILE ] && APPROF="`cat ${APPATH}/PROFILE`" || APPROF="(c) Andres Aquino <andres.aquino(at)gmail.com>"

  # log's path
  if [ ${#APLOGD} -eq 0 ]
  then
    APLOGD=${APPATH}/logs
  fi
  APLOGS=${APLOGD}/${APNAME}
  APTEMP=${APLOGD}/temp
  APLOGP=${APTEMP}/${APNAME}
  [ ! -d ${APLOGD} ] && mkdir -p ${APLOGD}
  [ ! -d ${APTEMP} ] && mkdir -p ${APTEMP}

  # key file to cipher/decipher information
  APKEYF="${APHOME}/${APNAME}.key"
  
  HOSTNAME=`hostname`
  case "${APSYSO}" in
    "HP-UX")
      PSOPTS="-l -f -a -x -e"
      PSPOS=1
      DFOPTS="-P -k"
      MKOPTS="-d /tmp -p "
      APUSER=`id -u -n`
      ECOPTS=""
      PING="`which ping`"
      PINGPARAMS="-n"
      IFCONFIG="`which ifconfig`"
      IFPARAMS="lan"
      MAIL=`which mailx`
      TAR=`which tar`
      ZIP=`which gzip`
      SCREEN=`which screen`
      IPADDRESS=`${PING} ${HOSTNAME} -n 1 | awk '/icmp_=/{print $0}' | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*$/\1/'`
    ;;
      
    "Linux")
      PSOPTS="lax"
      PSPOS=0
      DFOPTS="-Pk"
      MKOPTS="-t "
      APUSER=`id -u `
      ECOPTS=""
      PING="`which ping`"
      PINGPARAMS="-c"
      IFCONFIG="`which ifconfig`"
      IFPARAMS="eth"
      MAIL=`which mail`
      TAR=`which tar`
      ZIP=`which gzip`
      SCREEN=`which screen`
      IPADDRESS=`${PING} -c 1 ${HOSTNAME} | awk '/icmp_seq=/{print $0}' | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*$/\1/'`
    ;;
    
    "Darwin")
      PSOPTS="-leax"
      PSPOS=-1
      DFOPTS="-P -k"
      MKOPTS="-t "
      APUSER=`id -u `
      ECOPTS=""
      PING="`which ping`"
      PINGPARAMS="-c"
      IFCONFIG="`which ifconfig`"
      IFPARAMS="en"
      MAIL=`which mail`
      TAR=`which tar`
      ZIP=`which gzip`
      SCREEN=`which screen`
      IPADDRESS=`${PING} -c 1 ${HOSTNAME} | awk '/icmp_seq=/{print $0}' | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*$/\1/'`
    ;;
      
    *)
      PSOPTS="-l"
      PSPOS=0
      IPADDRESS="127.0.0.1"
    ;;
  esac

  # print a report
  logAction "INFO" "${APNAME} starting, you're using ${APSYSO} Operating System"
  logAction "DEBUG" ""
  logAction "DEBUG" ""
  logAction "DEBUG" ""
  logAction "DEBUG" ""
  logAction "DEBUG" ""
  logAction "DEBUG" ""
  logAction "DEBUG" ""
  logAction "DEBUG" ""
  logAction "DEBUG" ""
}


#
# set Application's Name
setName () {
  local AP_NAME=${1}
  local AP_PATH=${2}

  APNAME=${AP_NAME}
  APPATH=${AP_PATH}
  [ ! -d ${APPATH} ] && mkdir -p ${APPATH}
  
  #APLOGD=${APHOME}/logs
  APLOGS=${APLOGD}/${APNAME}
  [ ! -d ${APLOGD} ] && mkdir -p ${APLOGD}

  APTEMP=${APLOGD}/temp
  [ ! -d ${APTEMP} ] && mkdir -p ${APTEMP}

  APLOGP=${APTEMP}/${APPRCS}
  
}


#
# set log
setLogs () {
  local AP_LOGD=${1}

  # log's path
  [ -d ${APLOGD} ] && echo "del ${APLOGD}"
  APLOGD=${AP_LOGD}
  APLOGS=${APLOGD}/${APNAME}
  [ ! -d ${APLOGD} ] && mkdir -p ${APLOGD}

  [ -d ${APTEMP} ] && echo "del ${APTEMP}"
  APTEMP=${APLOGD}/temp
  [ ! -d ${APTEMP} ] && mkdir -p ${APTEMP}

}


#
# set processes
setProcess () {
  local AP_PROC=${1}

  # process name
  export APPRCS=${AP_PROC}
  export APLOGP=${APLOGD}/${APPRCS}
  export APLOGT=${APTEMP}/${APPRCS}

}

#
# get the process ID of an app
#  FILTER = strings to look for in process list (ej. java | rmi;java | iplanet,cci)
#  PROCID = IDname for process (ej. iplanets)
getProcessID () {
  #
  local FILTER="${1}"
  
  [ ${#FILTER} -ne 0 ] && APFLTR=${FILTER}
  PIDFILE=${APLOGT}
  WRDSLIST=`echo  "${APUSER},${APFLTR}" | sed -e "s/\///g;s/,/\/\&\&\//g;s/;/\/\|\|\//g"` 
  # extraer procesos existentes y filtrar las cadenas del archivo de configuracion
  ps ${PSOPTS} > ${PIDFILE}.allps
  logAction "DEBUG" "filtering process list with [ps ${PSOPTS}]"
  ${VIEWMLOG} && showStatus "i" "Creating of ${PIDFILE}.allps"
  
  # extraer los procesos que nos interesan 
  awk "/${WRDSLIST}/{print}" ${PIDFILE}.allps > ${PIDFILE}.ps
  logAction "DEBUG" "looking for /${WRDSLIST}/ in ${PIDFILE}.allps owned by ${APUSER}"
  
  # el archivo existe y es mayor a 0 bytes 
  if [ -s ${PIDFILE}.ps ]
  then
    ${VIEWMLOG} && showStatus "i" "${PIDFILE}.allps < /${WRDSLIST}/ = uju!"
    # extraer los procesos y reordenarlos
    sort -n -k8 ${PIDFILE}.ps > ${PIDFILE}.pss
    logAction "DEBUG" "hey, we have one ${APPRCS} process alive in ${PIDFILE}.ps "
    
    # extraer los pid de los procesos implicados 
    awk -v P=${PSPOS} '{print $(3+P)}' ${PIDFILE}.pss > ${PIDFILE}.pid
    
    # reodernar los PPID para dejar el proceso raiz al final
    awk -v P=${PSPOS} '{print $(4+P)}' ${PIDFILE}.pss | sort -rn | uniq > ${PIDFILE}.ppid

  else
    ${VIEWMLOG} && showStatus "i" "${PIDFILE}.allps < /${WRDSLIST}/ = dawm!"
    # eliminar archivos ppid, en caso de que el proceso ya no exista
    logAction "DEBUG" "hey, ${APPRCS} is not running in ${PIDFILE}.ps "
    rm -f ${PIDFILE}.{pid,ppid}
  fi
  rm -f ${PIDFILE}.{pss}
}

#
# verify the PID's for a specific process
isProcessRunning () {
  local COUNT=0
  local EACH=""

  # toma de base el APPRCS que se encuentra instanciada 
  PIDFILE=${APLOGT}
  logAction "DEBUG" "looking for ${PIDFILE}.pid"

  # si no existe el PID, forzar la busqueda 
  [ ! -s ${PIDFILE}.pid ] && getProcessID

  # caso contrario, verificar que sea correcto 
  if [ -s ${PIDFILE}.pid ]
  then
    PROCESS=`head -n1 ${PIDFILE}.pid`
    ${VIEWMLOG} && showStatus "i" "${PIDFILE}.pid > [ ${PROCESS} ]"
    kill -0 ${PROCESS} > /dev/null 2>&1
    RESULT=$?
    [ ${RESULT} -ne 0 ] && STATUS="process ${APPRCS} is not running"
    [ ${RESULT} -eq 0 ] && STATUS="process ${APPRCS} is running"
    ${VIEWMLOG} && showStatus "i" "Well, ${STATUS} (kill -0 PID)"
    logAction "DEBUG" "${STATUS}"
    return ${RESULT}
  else
    rm -f ${PIDFILE}.*
    return 1
  fi
}



#
# verify the PID's for a specific process
searchProcess () {
  local COUNT=0
  local EACH=""

  for PIDFILE in ${APTEMP}/*.pid
  do
    # si no existe el archivo de .pid, reportarlo y terminar
    if [ -s ${PIDFILE} ]
    then
      PROCESS=`head -n1 ${PIDFILE}`
      kill -0 ${PROCESS} > /dev/null 2>&1
      RESULT=$?
      [ ${RESULT} -ne 0 ] && logAction "DEBUG" "${PIDFILE} is not a valid process"
      [ ${RESULT} -ne 0 ] && rm -f ${PIDFILE}
      return ${RESULT}
    fi
  done
}


#
# event log
logAction () {
  local LEVEL="${1}"
  local ACTION="${2}"
  
  # filelog y process id
  local TIME="`date '+%H:%M:%S'`"
  local DATE="`date '+%Y-%m-%d'`"
  local PID="$$"
  # verificar que existe (mayor a 0 bytes) y ademas se cuenta con el process id
  if [ -s ${APLOGS}.pid ] 
  then 
    PID=`head -n1 ${APLOGP}.pid`
  fi
    
  # severity level: http://www.aboutdebian.com/syslog.htm
  # do you need make something for whatever level on your app ? 
  LOGTHIS=false
  case "${LEVEL}" in
    "ALERT")
      LOGTHIS=true
    ;;
    "EMERG"|"CRIT"|"ERR")
      LOGTHIS=true
    ;;
    "WARN")
      [ ${APLEVL} = "WARN" ] && LOGTHIS=true
      [ ${APLEVL} = "NOTICE" ] && LOGTHIS=true
    ;;
    "NOTICE")
      [ ${APLEVL} = "NOTICE" ] && LOGTHIS=true
      [ ${APLEVL} = "DEBUG" ] && LOGTHIS=true
    ;;
    "DEBUG")
      [ ${APLEVL} = "DEBUG" ] && LOGTHIS=true
    ;;
    "INFO")
      [ ${APLEVL} = "INFO" ] && LOGTHIS=true
      [ ${APLEVL} = "NOTICE" ] && LOGTHIS=true
      [ ${APLEVL} = "DEBUG" ] && LOGTHIS=true
    ;;
  esac 
  
  if ${LOGTHIS}
  then
    if [ ${#APLOGS} -eq 0 ]
    then
      echo "${DATE} ${TIME} ${APHOST} ${PRNAME}[${PID}]: (${LEVEL}) ${ACTION}" 
    else
      echo "${DATE} ${TIME} ${APHOST} ${PRNAME}[${PID}]: (${LEVEL}) ${ACTION}" >> ${APLOGS}.log
    fi
  fi
}


#
# show status of app execution
showStatus () {
  local STATUS="${1}"
  local MESSAGE="${2}"
  
  # cadena para indicar proceso correcto o con error
  echo " ${MESSAGE} " | awk -v STATUS=${STATUS} '{print substr($0"                                                                                        ",1,80),STATUS}'
  if [ "${#TXTBLU}" -ne 0 ] 
  then 
    tput sc 
    tput cuu1 && tput cuf 80
    case "${STATUS}" in
      "*")
        toPrint "${CRESET}[${TXTGRN} ${STATUS} ${CRESET}]"
      ;;
      "?")
        toPrint "${CRESET}[${TXTRED} ${STATUS} ${CRESET}]"
      ;;
      "i")
        toPrint "${CRESET}[${TXTYLW} ${STATUS} ${CRESET}]"
      ;;
    esac
  fi
}


#
# toSearch
toSearch () {
  local FILTER="${1}"
  local WRDSLIST=`echo "${FILTER}" | sed -e "s/\///g;s/,/\/\&\&\//g;s/;/\/\|\|\//g"` 

  # la long de la cad no esta vacia
  [ ${#FILTER} -eq 0 ] && logAction "DEBUG" "Umh, please set the filter (UP or DOWN)String"
  [ ${#FILTER} -eq 0 ] && return 1

  # extraer los procesos que nos interesan 
  [ ! -f ${APLOGP}.log ] && touch ${APLOGP}.log
  cut -c1-160 ${APLOGP}.log | awk "BEGIN{res=0}/${WRDSLIST}/{res=1}END{if(res==0){exit 1}}"
  LASTSTATUS=$?
  logAction "DEBUG" "ok, searching /${WRDSLIST}/ in ${APLOGP}.log: ${LASTSTATUS}"
  
  if [ ${LASTSTATUS} -eq 0 ]
  then
    logAction "DEBUG" "search of /${FILTER}/ was succesfull"
  else
    logAction "DEBUG" "search of /${FILTER}/ was failed"
  fi

  return ${LASTSTATUS}
}


toPrint () {
  local message="$1"

  _echo=`which echo`
  case "${APSYSO}" in
    "HP-UX")
      $_echo "$message"
    ;;
      
    "Linux")
      $_echo -e -n "$message \n"
    ;;
    
    "Darwin")
      $_echo -e -n "$message \n"
    ;;
      
    *)
      $_echo "$message *"
    ;;
  esac

}

#
# waiting process indicator
statusWaiting () {
  local WAITSTR="- \ | / "
  local STATUS=${1}
  local TIMETO=${2}
  local GOON=true
  local WAITCHAR="-"
  
  [ ${#TIMETO} -eq 0 ] && TIMETO=1

  if [ "${#TXTBLU}" -ne 0 ] 
  then
    if [ "${STATUS}" != "CLEAR" ]
    then
      TIMETO=$((${TIMETO}*5))
      toPrint " >>${STATUS} " | awk '{print substr($0"                                                                                        ",1,80)}'
      tput sc
      CHARPOS=1
      while(${GOON})
      do
        WAITCHAR=`echo ${WAITSTR} | cut -d" " -f${CHARPOS}`
        # recuperar la posicion en pantalla, ubicar en la columna 70 y subirse un renglon 
        tput rc
        tput cuu1 && tput cuf 80 
        toPrint "${CRESET}[${TXTYLW} ${WAITCHAR} ${CRESET}]"
        # incrementar posicion, si es igual a 5 regresar al primer caracter 
        CHARPOS=$((${CHARPOS}+1))
        [ ${CHARPOS} -eq 5 ] && CHARPOS=1
        perl -e 'select(undef,undef,undef,.1)'
        TIMETO=$((${TIMETO}-1))
        [ ${TIMETO} -eq 0 ] && GOON=false
      done
    else
      # limpiar linea de mensajes
      tput rc 
      tput cuu1
      tput el
    fi
    # limpiar linea de mensajes
    tput rc 
    tput cuu1
    #tput el
  else
    echo " >>${STATUS} " | awk '{print substr($0"                                                                                        ",1,80)}'
    while(${GOON})
    do
      sleep 1
      TIMETO=$((${TIMETO}-1))
      [ ${TIMETO} -lt 0 ] && GOON=false
    done
  fi
}

# use openssl for encrypt/decrypt information
getUser () {
  info=`openssl enc -d -aes256 -salt -pass file:${APKEYF} -in ${APHOME}/${1}`
  echo ${info%@*}

}

getPassword () {
  info=`openssl enc -d -aes256 -salt -pass file:${APKEYF} -in ${APHOME}/${1}`
  echo ${info#*@}

}

java16 () {
  PATH=/opt/java6/bin:${PATH}
}

java15 () {
  PATH=/opt/java1.5/bin:${PATH}
}

java14 () {
  PATH=/opt/java1.4/bin:${PATH}
}


#
