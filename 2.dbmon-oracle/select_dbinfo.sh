#!/bin/bash
rm -rf dbinfo.log
sqlplus  / as sysdba <<EOF
set feedback off
set trimspool on
set term off
spool dbinfo.log
exec DBMS_OUTPUT.PUT_LINE('created  by toad,any question can email to toaddb@163.com');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|           data dictionary hit ratio            |');
exec DBMS_OUTPUT.PUT_LINE('|           should be between 95%~99%            |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
select (sum(gets-getmisses-fixed))/sum(gets) "data dictionary hit ratio" from v\$rowcache;

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|        library cache  hit ratio                |');
exec DBMS_OUTPUT.PUT_LINE('|        should be 99% or higer                  |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
select sum(pinhits)/sum(pins) Library_cache_hit_ratio from v\$librarycache;

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|         efficiency of library cache            |');
exec DBMS_OUTPUT.PUT_LINE('|      less reloads and more hits is requred     |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
select namespace,pins,pinhits,reloads from v\$librarycache order by namespace;

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|       the number of parses and hard parses     |');
exec DBMS_OUTPUT.PUT_LINE('|          associate with the session id         |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
select s.sid,s.value "Hard Parses", t.value "Executions Count" from v\$sesstat s,v\$sesstat t where s.sid=t.sid and s.statistic#=(select statistic# from v\$statname where name='parse count (hard)') and t.statistic#=(select statistic# from v\$statname where name='execute count') and s.value >0;

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|  data buffer hit ratio,the higer the better    |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
select name,physical_reads,db_block_gets,consistent_gets,1-(physical_reads/(db_block_gets+consistent_gets)) "HitRatio" from v\$buffer_pool_statistics;

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|            the io distribution                 |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
col name format a35
select d.name,f.phyrds reads,f.phywrts wrts,(f.readtim / decode(f.phyrds,0,-1,f.phyrds)) readtime,    (f.writetim / decode(f.phywrts,0,-1,phywrts)) writetime from v\$datafile d,v\$filestat f where d.file#=f.file# order by d.name;

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|       the ratio of database Wait Time          |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
select metric_name,value from v\$sysmetric where metric_name in ('Database CPU Time Ratio','Database Wait Time Ratio') and INTSIZE_CSEC=(select max(INTSIZE_CSEC) from v\$sysmetric);

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|  time waited event which is more than 1 second |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
select event,time_waited,average_wait from v\$system_event where TIME_WAITED > 100 order by time_waited desc;

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|         users sqltext and his event            |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
select s.username,t.sql_text,s.event from v\$session s,v\$sqltext t where s.sql_hash_value = t.hash_value and s.sql_address=t.address and s.type <> 'BACKGROUD' order by s.sid,t.hash_value,t.piece;

exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|          the wait event of the last 5 min      |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
col object_name format a15
col event format a30
select o.object_name,o.object_type, a.event, sum(a.wait_time + a.time_waited) total_wait_time from v\$active_session_history a,dba_objects o where a.sample_time between sysdate-10/2880 and sysdate and a.current_obj# = o.object_id group by o.object_name,o.object_type,a.event order by total_wait_time desc;


exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|           the most busy sql of the last 5 min  |');
exec DBMS_OUTPUT.PUT_LINE('|                                                |');
exec DBMS_OUTPUT.PUT_LINE('|------------------------------------------------|');
col username format a15
select a.user_id,d.username,s.sql_text,sum(a.wait_time+a.time_waited) total_wait_time from v\$active_session_history a,v\$sqlarea s,dba_users d where a.sample_time between sysdate - 10/2880 and sysdate and a.sql_id = s.sql_id and a.user_id = d.user_id group by a.user_id,s.sql_text,d.username;




spool off
EOF

sed  -i '/@/d' dbinfo.log
