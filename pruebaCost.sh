#!/bin/sh

export RUTA='/opt/batch/credit'
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

pruebaCost(){
echo $ORACLE_SID
echo $usCost
$ORACLE_HOME/bin/sqlplus -S $usCost/$passCost@$ORACLE_SID<<EOF
PROMPT Sin errores al conectarse a Cost
PROMPT 
PROMPT Cuscode | Customer ID

SET SERVEROUT ON

DECLARE
CURSOR prueba is
SELECT custcode, customer_id
FROM cost.cost_clientes
WHERE ROWNUM <= 10;
resultado prueba%ROWTYPE;

BEGIN
	OPEN prueba;
		LOOP 
			FETCH prueba
			INTO resultado;
			EXIT WHEN prueba%NOTFOUND;
			dbms_output.put_line(resultado.custcode||'|'|| resultado.customer_id);
			--PRINT resultado;
		END LOOP;
	CLOSE prueba;
END;
/

exit
EOF
date
codSt=$?
if [ ! $codSt = 0 ];then
echo "ERROR EN EL REPORTE" $1
codST=2
fi
return $codST 
}

export ORACLE_HOME=/oracle/app/oracle/product/10.2.0.3
export ORACLE_SID=COST_CONTROL
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export TS=`date +%s`
sh_user
pruebaCost
codSt=$?
echo $codSt
if [  $codSt = 0 ];then
echo "Query corrio OK"
else
echo "ERROR"
exit -1
fi
exit 0