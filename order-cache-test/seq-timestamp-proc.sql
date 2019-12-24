

create or replace procedure seq_timestamp (
	seq_value_out out pls_integer
	, seq_timestamp_out out timestamp
	, enable_locking boolean default true
)
as
	seqValueOut pls_integer;
	seqTimestamp timestamp;
	lockHandle varchar2(128);
	lockAcquired boolean := false;
	glockResult integer;
	localInstanceNumber integer;
	sleptTime number;

	-- if lock not obtained within ~0.25 seconds, then return false
	-- the transaction should proceed without the lock and log the issue
	function get_lock (lockHandleIn varchar2, sleptTimeInOut in out number ) return boolean
	is

		type backoffTyp is table of number;
		-- new in 18c - initialize and assign in one command
		--timeoutBackoff backoffTyp := backoffTyp(0.01,0.05,0.07,0.10);
		-- try very hard to get the lock
		timeoutBackoff backoffTyp := backoffTyp(0.01,0.05,0.07,0.10,0.25,0.5,1.0,2.0,3.0);
		flockResult integer;

	begin

		--dbms_output.enable(null);
		sleptTimeInOut := 0;

		for i in timeoutBackoff.first .. timeoutBackoff.last
		loop
			
			flockResult := dbms_lock.request (
				lockhandle => lockHandleIn,
				lockmode => dbms_lock.x_mode,
				timeout => 0,
				release_on_commit => TRUE /* default is false */
			);

			if flockResult = 0 then
				return true;
			end if;
		
			sleptTimeInOut := timeoutBackoff(i);
			dbms_lock.sleep(timeoutBackoff(i));

		end loop;

		return false;

	end;

	procedure allocate_lock (lockHandleIN out varchar2)
	is
		pragma autonomous_transaction;
	begin
		dbms_lock.allocate_unique(
			lockName => 'SEQ_TIMESTAMP_COORD',
			lockHandle => lockHandleIn
		);
	end;

	procedure log_lock_failure (
		idIn number
		, seqTimeIn timestamp
		, sleptTimeIn number
		, instIdIn number
	)
	is
		pragma autonomous_transaction;
	begin
		insert into seq_test_log(id,seq_time,slept_time,inst_id)
		values(idIn,seqTimeIn,sleptTimeIn,instIdIn);
		commit;
	end;

begin

	select instance_number into localInstanceNumber from v$instance;

	-- serialize with dbms_lock
	if enable_locking then 
		allocate_lock(lockHandle);
		--dbms_output.put_line('lock handle: ' || lockHandle);

		-- if lock is not acquired, do not fail the function
		-- this is where failing to get the lock would be logged
		lockAcquired := get_lock(lockHandle,sleptTime);
	end if;

	select seq_cache_test.nextval, systimestamp into seq_value_out, seq_timestamp_out from dual; --@timekeeper;


	if enable_locking then 
		if lockAcquired then

			glockResult := dbms_lock.release(
				lockHandle => lockHandle
			);

		else

			-- here is where to log the failure to obtain the lock
			log_lock_failure(seq_value_out,seq_timestamp_out,sleptTime,localInstanceNumber);

		end if;
	end if;

end;
/

show error procedure seq_timestamp

