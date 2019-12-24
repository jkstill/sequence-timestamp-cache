



srvctl add service -db cdb -pdb pdb1 -service timekeeper -preferred cdb1 -available cdb2

srvctl start service -service timekeeper -db cdb  -node rac19c01

create database link timekeeper using '(description=(address=(protocol=tcp)(host=rac19c-scan)(port=1521))(connect_data=(service_name=timekeeper.jks.com)))'





