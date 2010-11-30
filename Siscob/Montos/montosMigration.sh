#!/bin/sh

export RUTA='/opt/apps/batch/CostControl'
sh_user(){
archivoSiscob=$RUTA/userSISCOB.txt
export passSiscob=`cat $archivoSiscob | awk '
{ if(substr($0,1,4)=="PWD=")
      print substr($0,5,20);
   }'`
export usSiscob=`cat $archivoSiscob | awk '
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
carteras(){
date
$ORACLE_HOME/bin/sqlplus -s $usSiscob/$passSiscob@$ORACLE_SID<<EOF
SET HEAD OFF
SET TAB ON
SET TRIMOUT ON
SET PAGESIZE 0
SET COLSEP '|'
SET FEEDBACK OFF
SET ECHO ON
SET TRIMSPOOL ON
SET TERM ON
SET LINESIZE 350
SET SERVEROUT ON

spool montosSiscob.csv
declare
cursor migracion_datos is SELECT customer_id customer_id, clim_monto monto , model_id tipo
  FROM nexsco.sco_credit_limit
 WHERE clim_status = 'AC' AND model_id IN (1, 3);
 resultado migracion_datos%rowtype;

  begin
   OPEN migracion_datos;
            LOOP
         FETCH migracion_datos
          INTO resultado;
         EXIT WHEN migracion_datos%NOTFOUND;
		 	
             dbms_output.put_line(resultado.customer_id||'|'|| resultado.monto||'|'|| resultado.tipo);         
             END LOOP;
             close migracion_datos;
  end;

/
spool off
exit
EOF
date
codSt=$?
echo $codSt
if [ ! $codSt = 0 ];then
echo "ERROR EN EL REPORTE" $1
codST=2
fi
return $codST
}

#export ORACLE_HOME=/oracle/app/oracle/product/10.2.0.3
#export ORACLE_SID=SISCOB
#export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export TS=`date +%s`
sh_user
carteras
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
