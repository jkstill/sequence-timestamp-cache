

col u_cache_order new_value u_cache_order noprint


set term off head off feed off
select decode(upper('&1'),'Y','order','noorder') u_cache_order from dual;
set term on head on feed on

alter sequence seq_cache_test &u_cache_order;

col sequence_name format a25
col order_flag format a7 head 'ORDERED'

select sequence_name, cache_size, order_flag
from user_sequences
where sequence_name  = 'SEQ_CACHE_TEST';

undef u_cache_order 1


