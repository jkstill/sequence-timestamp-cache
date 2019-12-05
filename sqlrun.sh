#!/bin/bash		


declare sqlrunPassword=grok
#declare server=ora192rac-scan
declare scanName=rac19c-scan
declare db=pdb1.jks.com

declare startSeq=$(sqlplus -L -S  jkstill/${sqlrunPassword}@${scanName}/${db} <<-EOF
	set feed off term off echo off pause off head off
	set pagesize 0
	select last_number from user_sequences where sequence_name = 'SEQ_CACHE_TEST';
	exit
EOF
)

startSeq=$( echo $startSeq | tr -d ' ')
#echo start: "|$startSeq|"

# show the sequence information
sqlplus -L -S  jkstill/${sqlrunPassword}@${scanName}/${db} <<-EOF
	set feed off term on echo off pause off head on
	set pagesize 100
	col sequence_name format a15
	col order_flag format a7 head 'ORDERED'
	select sequence_name, cache_size, order_flag, last_number from user_sequences where sequence_name = 'SEQ_CACHE_TEST';
	exit
EOF


#: << 'COMMENT'

# time in epoch seconds:nanoseconds
startTime=$(date '+%s.%N')

./sqlrun.pl \
	--exe-mode sequential \
	--connect-mode tsunami \
	--max-sessions 8 \
	--db  ${scanName}/${db} \
	--username jkstill \
	--password ${sqlrunPassword} \
	--parmfile parameters.conf \
	--sqlfile sqlfile.conf  \
	--exe-delay 0.005 \
	--runtime 120  > /dev/null
	#--trace 

#: << 'COMMENT'

# check for running sqlrun jobs

while [[ $(/bin/ps -o cmd | /bin/grep '[p]erl.*sqlrun.pl' | /usr/bin/wc -l) -gt 0 ]]
do
	sleep .25
done

echo 
echo

endTime=$(date '+%s.%N')

#COMMENT

declare endSeq=$(sqlplus -L -S  jkstill/${sqlrunPassword}@${scanName}/${db} <<-EOF
	set feed off term off echo off pause off head off
	set pagesize 0
	select last_number from user_sequences where sequence_name = 'SEQ_CACHE_TEST';
	exit
EOF
)

endSeq=$( echo $endSeq | tr -d ' ')
#echo end: "|$endSeq|"

seqCount=$( echo "$endSeq - $startSeq" | /usr/bin/bc)

elapsedSeconds=$( echo "$endTime - $startTime" | /usr/bin/bc)

seqPerSecond=$( echo "$seqCount / $elapsedSeconds" | /usr/bin/bc) 

echo "Sequences per second: $seqPerSecond"

#COMMENT


