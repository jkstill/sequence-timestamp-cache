
# Sequences, Timestamps and RAC

Testing how to guarantee that when generating an ID from a sequence, along with a timestamp on RAC, the timestamp for any ID will always be greater than any previous timestamp.

There are several things that could cause race conditions that prevent this from working

- Oracle internal code path
- multiple CPUs
- CPU - out of order execution

# Serialization with DBMS_LOCK

Some form of serialization is needed to guarantee the timestamps will always ascend.

This can be made to work with DBMS_LOCK, but it is somewhat expensive.

## Without Serialization

```bash
$  ./sqlrun.sh

SEQUENCE_NAME   CACHE_SIZE ORDERED LAST_NUMBER
--------------- ---------- ------- -----------
SEQ_CACHE_TEST        1000 Y             44001
Connection Test - JKSTILL - 71

Sequences per second: 648

```

## With Serialization

```
$  ./sqlrun.sh

SEQUENCE_NAME   CACHE_SIZE ORDERED LAST_NUMBER
--------------- ---------- ------- -----------
SEQ_CACHE_TEST        1000 Y             83001
Connection Test - JKSTILL - 66

Sequences per second: 217

```

## Without Caching or Serialization

The sequence was recreated with the ORDER and NOCACHE clauses, and tests run without locking

```bash

$  ./sqlrun.sh

SEQUENCE_NAME   CACHE_SIZE ORDERED LAST_NUMBER
--------------- ---------- ------- -----------
SEQ_CACHE_TEST           0 Y                 1
Connection Test - JKSTILL - 74


Sequences per second: 238
```

While this was slightly faster than the serialized method, it does not prevent out of order timestamps.

In 14278 transactions, 5829 of them contained timestamps that were out of order.

The '-000' indicates a timestamp that is out of order

```bash

@report.sql

     ID INST SEQ_TIME                       DIFF_TIME
------- ---- ------------------------------ ------------------------------
  14260    2 24-DEC-19 12.35.25.901760 PM   -000000000 00:00:00.028332
  14261    1 24-DEC-19 12.35.25.937587 PM   +000000000 00:00:00.035827
  14262    1 24-DEC-19 12.35.25.939310 PM   +000000000 00:00:00.001723
  14263    2 24-DEC-19 12.35.25.911983 PM   -000000000 00:00:00.027327
  14264    1 24-DEC-19 12.35.25.949544 PM   +000000000 00:00:00.037561
  14265    2 24-DEC-19 12.35.25.928079 PM   -000000000 00:00:00.021465
  14266    1 24-DEC-19 12.35.25.958808 PM   +000000000 00:00:00.030729
  14267    2 24-DEC-19 12.35.25.935448 PM   -000000000 00:00:00.023360
  14268    1 24-DEC-19 12.35.25.960794 PM   +000000000 00:00:00.025346
  14269    1 24-DEC-19 12.35.25.970212 PM   +000000000 00:00:00.009418
  14270    2 24-DEC-19 12.35.25.944426 PM   -000000000 00:00:00.025786
  14271    1 24-DEC-19 12.35.25.976371 PM   +000000000 00:00:00.031945
  14272    2 24-DEC-19 12.35.25.954821 PM   -000000000 00:00:00.021550
  14273    1 24-DEC-19 12.35.25.985044 PM   +000000000 00:00:00.030223
  14274    1 24-DEC-19 12.35.25.986407 PM   +000000000 00:00:00.001363
  14275    2 24-DEC-19 12.35.25.963315 PM   -000000000 00:00:00.023092
  14276    1 24-DEC-19 12.35.25.994382 PM   +000000000 00:00:00.031067
  14277    2 24-DEC-19 12.35.25.974950 PM   -000000000 00:00:00.019432
  14278    2 24-DEC-19 12.35.25.980648 PM   +000000000 00:00:00.005698
  14279    2 24-DEC-19 12.35.25.992245 PM   +000000000 00:00:00.011597

```

# linuxptp

Rather than serialization, more accurate timekeeping could be configured.

chrony can be configured to use the ptp protocol, allowing single digit microsecond accuracy of clocks in a cluster.

While this would not guarantee the timestamps would always be ascending, it does make it more likely.

More about linuxptp:

[http://linuxptp.sourceforge.net](http://linuxptp.sourceforge.net)

[CONFIGURING PTP USING PTP4L](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/ch-configuring_ptp_using_ptp4l)

For best results, an external (to the cluster) timekeeper server should be used.
The timekeeper should be on HW, not a virtual machine, as linuxptp can use the clock on the NIC.

This is particularly true for Virtual clusters, as there is no HW clock on the virtual NICs.


