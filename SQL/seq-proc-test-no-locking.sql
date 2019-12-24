
-- seq-proc-test.sql

declare

	-- run for this many seconds
	instId integer;
	id pls_integer;
	currTimestamp timestamp;

begin

	select instance_number into instId from v$instance;

	seq_timestamp(id,currTimestamp,false);

	insert into seq_test_table(id, seq_time, inst_id)
	values( id, currTimestamp, instId);

	commit;

end;

