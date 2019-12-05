
# Sequence Testing - ORDER and CACHE

Test if on RAC each instances gets the next value of sequence even with caching.

Don't yet know how this works internally, but it does appear to work.

# create the sequence

Create with `../sequence-ddl/create-cache-order.sql`


# create the test table

Testing is performed by inserting a row into a table from each RAC instance.

The pk (sequence) and timestamps should both be in ascending order

Use the `create-seq-test-table.sql` script

# run the test

Use the `seq-order-test.sql` script








