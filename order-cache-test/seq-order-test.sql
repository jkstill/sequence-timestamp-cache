
-- seq-order-test.sql

set serveroutput on size unlimited

declare

	-- run for this many seconds
	runTimeSeconds number := 3600;
	randomSeed integer := 42;
	randomLow number := .001;
	randomHigh number := .01;

	instId integer;
	id pls_integer;
	currTimestamp timestamp;

	startTime timestamp;
	endTime  timestamp;
	elapsedSeconds number := 0;

	function getSeconds ( beginTimestamp timestamp, endTimestamp timestamp ) return number
	is
		timestampInterval interval day to second;
		seconds number;
	begin

		timestampInterval := endTimestamp - beginTimestamp;

		seconds := 
			(extract ( day from timestampInterval ) * 86400 )
			+ (extract ( hour from timestampInterval ) * 3600 )
			+ (extract ( minute from timestampInterval ) * 60 )
			+ extract ( second from timestampInterval ) ;

		return seconds;

	end;

begin

	dbms_output.enable(null);

	startTime := systimestamp;

	-- function test
	--dbms_lock.sleep(2.749);
	--elapsedSeconds := getSeconds(startTime, endTime);
	--dbms_output.put_line('elapsed: ' || to_char(elapsedSeconds));

	select instance_number into instId from v$instance;

	dbms_random.seed(randomSeed);

	while elapsedSeconds < runTimeSeconds
	loop

		
		-- the negetive time differences appear in report.txt regardless of
		-- whether the nextval and timestamp are used directly in SQL or 
		-- assigned to variables

		id := seq_cache_test.nextval;
		currTimestamp := systimestamp;

		insert into seq_test_table(id, seq_time, inst_id)
		values( id, currTimestamp, instId);

		/*
		insert into seq_test_table(id, seq_time, inst_id)
		values( seq_cache_test.nextval, systimestamp, instId);
		*/

		commit;

		dbms_lock.sleep(dbms_random.value(randomLow, randomHigh));
		endTime := systimestamp;
		elapsedSeconds := getSeconds(startTime, endTime);

	end loop;

end;
/

