

col u_cache_size new_value u_cache_size noprint

set term off head off feed off
-- cache size of 1 not allowed
select decode(&1,0,'nocache', 1,'cache 2', 'cache &1') u_cache_size from dual;
set term on head on feed on

alter sequence seq_cache_test &u_cache_size;

col sequence_name format a25
col order_flag format a7 head 'ORDERED'

select sequence_name, cache_size, order_flag
from user_sequences
where sequence_name  = 'SEQ_CACHE_TEST';

undef cache_size 1



