
set linesize 200 trimspool on
set pagesize 100

col id format 999999
col seq_time format a30
col inst_id format 999 head 'INST'
col diff_time format a30

alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

set term off
spool report.txt

with data as (
	select id, seq_time
		, to_date(to_char(seq_time,'yyyy-mm-dd hh24:mi:ss')) seq_date
		, inst_id
	from seq_test_table
)
select id, inst_id, seq_time
	, seq_time - lag(seq_time) over ( order by id, seq_time) diff_time
	--, seq_date
	--, lag(seq_date) over ( order by id) lag_date
	--, seq_date - lag(seq_date) over ( order by id) diff_date
from data
order by id
/

spool off
set term on

ed report.txt

