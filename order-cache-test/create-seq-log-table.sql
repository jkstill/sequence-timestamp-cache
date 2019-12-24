
drop table seq_test_log purge;

create table seq_test_log ( id number not null, seq_time timestamp not null, slept_time number, inst_id number(2,0) not null);


