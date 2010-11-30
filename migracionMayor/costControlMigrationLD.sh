#!/bin/sh

export RUTA='/opt/apps/batch/CostControl'
sh_user(){
archivoCost=$RUTA/userCost.txt
export passCost=`cat $archivoCost | awk '
{ if(substr($0,1,4)=="PWD=")
      print substr($0,5,20);
   }'`
export usCost=`cat $archivoCost | awk '
{ if ( substr($0,1,4) == "USR=")
      print substr($0,5,20);
   }'`
}


calculaTiempo() {
tas=`date +%s`
echo $tas
tiempo=`expr $tas - $TS`
seconds=`expr $tiempo % 60`
tempSec=`expr $tiempo - $seconds`
tempMin=`expr $tempSec / 60`
minutos=`expr $tempMin % 60`
temph=`expr $tempMin - $minutos`
horas=`expr $temph / 60`
echo $horas:$minutos:$seconds
}
loadCuentas(){
$ORACLE_HOME/bin/sqlldr	 $usCost/$passCost@$ORACLE_SID control=/opt/apps/batch/CostControl/migracionMayor/loaderCost.txt<<EOF
EOF
codSt=$?
if [ ! $codSt = 0 ];then
echo "ERROR EN EL REPORTE" $1
codST=2
fi
return $codST 
}
loadEquipos(){
$ORACLE_HOME/bin/sqlldr	 $usCost/$passCost@$ORACLE_SID control=/opt/apps/batch/CostControl/migracionMayor/loaderCostEqs.txt<<EOF
EOF
codSt=$?
if [ ! $codSt = 0 ];then
echo "ERROR EN EL REPORTE" $1
codST=2
fi
return $codST 
}
#export ORACLE_HOME=/oracle/app/oracle/product/10.2.0.3
export ORACLE_SID=COST_CONTROL
#export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export TS=`date +%s`
sh_user
echo $usCost
loadCuentas
loadEquipos
calculaTiempo
codSt=$?
echo $codSt
if [  $codSt = 0 ];then
echo "Query corrio OK"
else
echo "ERROR"
exit -1
fi
exit 0

