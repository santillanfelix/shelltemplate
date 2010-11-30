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

equipos(){
date
$ORACLE_HOME/bin/sqlplus -s $userBscs/$passBscs@$ORACLE_SID<<EOF
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

SPOOL contratos_MovDiario.csv
DECLARE
   CURSOR contratos
   IS
      select customer_id, co_id, tmcode, creacion from (SELECT ca.customer_id, ca.co_id, ca.tmcode,
       TO_CHAR (ca.co_entdate, 'yyyymmdd') creacion
  FROM contract_all ca, contr_devices cd
 WHERE ca.ch_status <> 'd'
 and ca.co_id = cd.co_id
 and cd.cd_deactiv_date is null);
 resultado   contratos%ROWTYPE;
   custo     NUMBER;
   susp_totales NUMBER;
   susp_cheques	NUMBER;	
   renta	NUMBER;

BEGIN
   OPEN contratos;
   LOOP
      FETCH contratos
       INTO resultado;
      EXIT WHEN contratos%NOTFOUND;
SELECT customer_id  into custo  from (
SELECT customer_id, custcode, level lv 
      FROM sysadm.customer_all 
        where paymntresp = 'X'
START WITH customer_id = resultado.customer_id                    --aqui va el customerId
CONNECT BY prior customer_id_high = customer_id ORDER BY LV asc ) a
where rownum = 1;

begin

select nvl(max(susp),0) into susp_totales from (
		select ca.CUSTOMER_ID, count(1) susp from contract_history ch, contract_all ca where ch_reason in (SELECT rea.RS_ID
		  FROM sysadm.reasonstatus_all rea
		WHERE rs_desc IN
	          ('1 SUSP. FALTA DE PAGO',
        	   '3 SUSP. POR FRAUDE',
	           '7 SUSP. RECHAZO CARGO RECURRENTE',
        	   '8 SUSP. PLANES PERSONALES'
        	   ))
	  AND ca.CO_ID = resultado.co_id
	  and ca.CO_ID = ch.CO_ID
	  and entdate > add_months(sysdate, -6)
	group by ch.co_id, ca.CUSTOMER_ID
	) tot;

exception when no_data_found then
susp_totales := 0;
end;

begin
select nvl(max(susp),0) into susp_cheques from (
	select ca.CUSTOMER_ID, count(1) susp from 
	sysadm.contract_history ch, 
	sysadm.contract_all ca 
	where ch_reason in (SELECT rea.RS_ID
	  FROM sysadm.reasonstatus_all rea
	WHERE rs_desc ='2 SUSP. POR CHEQUE DEVUELTO')
	  AND ca.CO_ID = resultado.co_id
	  and ca.CO_ID = ch.CO_ID
	  and entdate > add_months(sysdate, -6)
	group by ch.co_id, ca.CUSTOMER_ID
	)cheq;

exception when no_data_found then
susp_cheques := 0;

end;

SELECT   SUM (accessfee) into renta
    FROM (SELECT a.co_id, a.sncode, b.spcode
            FROM sysadm.pr_serv_spcode_hist a,
                 sysadm.mpusptab b,
                 sysadm.profile_service c,
                 sysadm.mpusntab d
           WHERE a.spcode = b.spcode
             AND d.sncode = a.sncode
             AND c.spcode_histno = a.histno
             AND a.co_id = c.co_id) a,
         (SELECT   tmb.tmcode, MAX (tmb.vscode) vscode
              FROM sysadm.mpulktmb tmb
             WHERE tmb.status = 'P'
          GROUP BY tmb.tmcode) b,
         sysadm.mpulktmb tmb
   WHERE a.sncode = tmb.sncode
     AND a.spcode = tmb.spcode
     AND b.tmcode = tmb.tmcode
     AND b.vscode = tmb.vscode
     AND b.tmcode = resultado.tmcode
     AND a.co_id = resultado.co_id
GROUP BY a.co_id;

      DBMS_OUTPUT.put_line (   custo
                            || '|'
                            || resultado.co_id
                            || '|'
                            || resultado.tmcode
                            || '|'
                            || renta
			    || '|'
                            || resultado.creacion
                            || '|SISTEMA|'
			    || susp_totales
		 	    || '|'
			    || susp_cheques
			    
                           );
   END LOOP;
   CLOSE contratos;
END;    
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

export ORACLE_HOME=/oracle/app/oracle/product/10.2.0.3
export ORACLE_SID=BSCS_ONLINE
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export TS=`date +%s`
sh_user
echo $usCost

equipos
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

