#!/bin/sh

export RUTA='/opt/batch/credit'
sh_user(){
archivoBscs=$RUTA/userBSCS.txt
export passBscs=`cat $archivoBscs | awk '
{ if(substr($0,1,4)=="PWD=")
      print substr($0,5,20);
   }'`
export userBscs=`cat $archivoBscs | awk '
{ if ( substr($0,1,4) == "USR=")
      print substr($0,5,20);
   }'`
}

pruebaBSCS(){
echo $ORACLE_SID
echo $userBscs
$ORACLE_HOME/bin/sqlplus -s $userBscs/$passBscs@$ORACLE_SID<<EOF
PROMPT Sin errores al conectarse a BSCS
PROMPT 
PROMPT Cuscode | Customer ID

SET SERVEROUT ON

DECLARE
CURSOR prueba is
SELECT custcode, customer_id
FROM sysadm.customer_all
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
export ORACLE_SID=BSCS_ONLINE
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export TS=`date +%s`
sh_user
pruebaBSCS
codSt=$?
echo $codSt
if [  $codSt = 0 ];then
echo "Query corrio OK"
else
echo "ERROR"
exit -1
fi
exit 0
