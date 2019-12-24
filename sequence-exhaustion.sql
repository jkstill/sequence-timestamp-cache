
-- the maximum value of 2^32-1 is imposed by a VOIP protocol
-- this calculation is to show the difference between caching 1000 per node
-- and expecting to lose the cache 10 times a day, vs caching 20 per node
-- and losing the cache once per day
-- the difference is about .8 days

-- format wrapped preserves leading spaces in dbms_output.put_line when used from sqlplus
set serveroutput on size unlimited format wrapped

set trimspool on

declare

	type intType is table of integer;
	-- new in 18c - initialize and assign in one command
	cacheSizeArray intType := intType(10,100,1000,10000);
	lostCount intType := intType(1,10,100);
	nodeCount integer := 2;
	seqUsedPerDay integer := 15000000;

	-- max sequence - half already used
	maxSeqVal integer := (power(2,32)-1);
	maxSeqAvailable integer := floor((power(2,32)-1) / 2);

	daysLeft number;
	
	separator char := '|';
	headerNumberFormat varchar2(20) := '9999999999';

begin

	dbms_output.enable(null);
	dbms_output.put_line('maximum sequences available: ' || to_char(maxSeqVal, headerNumberFormat));
	dbms_output.put_line('current sequences available: ' || to_char(maxSeqAvailable, headerNumberFormat));
	dbms_output.put_line('                 node count: ' || to_char(nodeCount, headerNumberFormat));
	dbms_output.put_line('');

	for i in cacheSizeArray.first .. cacheSizeArray.last
	loop
		for c in lostCount.first .. lostCount.last
		loop

			select  
				maxSeqAvailable /
				(
					(
						cacheSizeArray(i) -- cache size
						* lostCount(c) -- lose 10 per day
						*  nodeCount -- nodes
					)
					+ seqUsedPerDay -- used per day
				)
			into daysLeft
			from dual;

			dbms_output.put_line(
				'cache size: ' || to_char(cacheSizeArray(i),'09999')
				|| ' ' || separator || ' lost count: ' || to_char(lostCount(c),'099')
				|| ' ' || separator || ' days left: ' || to_char(daysLeft,'0999')
			);

		end loop;
	end loop;

end;
/


