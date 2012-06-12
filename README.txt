PgDeploy - PostgreSQL function deployment system

DESCRIPTION

Watch the diff of the function's source code you are
about to deployed, compared to the source code in
PostgreSQL, before actually deploying.



RATIONALE

There is no best practise standard way of deploying functions in PostgreSQL,
everybody seems to be doing it in a lot of different ways, so why not one.

Using a VCS like git to keep track of changes to your stored procedures
is easy, and most people are probably doing it and thinks it works fine.

In the database, there is only one version of the function though,
and this version should of course be 100% identical with the one in your VCS.

To prevent errors, easily caused by human errors, strict routines and
procedures must be managed, to make sure noone changed the functions
directly in the database, or commits to the VCS but forgets to deploy,
or deploys before commiting to the VCS, or any other human error.

There are probably tools to link the VCS directly to the database,
so function changes are deployed automatically when tagged
or something like that. Personally, I would not trust such a system,
it would feel scary doing deployments automatically, but that's
probably just me being paranoid and falsely believing not everything
can be automated.

By always using this function when deploying stored procedures,
you will always see the diff of the function before deploying,
and get a chance to spot any unexpected rows in the diff.



INTRODUCTION

PgDeploy adds an additional security layer when deploying functions in
PostgreSQL, letting you preview changes before actually deploying.

If the version of the function in the production database would be different
than the one in your VCS, this gives you a second change of detecting it.

This will save you in case someone has modified a function directly in
the database, without commiting to the VCS.




SYNOPSIS

git clone git://github.com/joelonsql/PgDeploy.git
cd PgDeploy
psql -f install.sql
psql

postgres=# \df deploy
                                     List of functions
 Schema |  Name  | Result data type |             Argument data types             |  Type  
--------+--------+------------------+---------------------------------------------+--------
 public | deploy | text             | OUT changes text, _sql text, _md5 character | normal
(1 row)

Step 1: Preview

postgres=# SELECT deploy($DEP$
postgres$# CREATE OR REPLACE FUNCTION calc_value_added_tax(amount numeric) RETURNS NUMERIC AS $$
postgres$# DECLARE
postgres$# _vat numeric := 0.125;
postgres$# BEGIN
postgres$# RETURN amount * (1 + _vat);
postgres$# END;
postgres$# $$ LANGUAGE plpgsql IMMUTABLE;
postgres$# $DEP$, NULL);
                      deploy                      
--------------------------------------------------
 +-------------------+                           +
 | Removed functions |                           +
 +-------------------+                           +
                                                 +
                                                 +
                                                 +
 +---------------+                               +
 | New functions |                               +
 +---------------+                               +
                                                 +
                                                 +
                                                 +
 +-------------------------------+               +
 | Updated or replaced functions |               +
 +-------------------------------+               +
                                                 +
 Schema................: public                  +
 Name..................: calc_value_added_tax    +
 Argument data types...: amount numeric          +
 Result data type......: numeric                 +
 Language..............: plpgsql                 +
 Type..................: normal                  +
 Volatility............: IMMUTABLE               +
 Owner.................: postgres                    +
 3 c _vat numeric := 0.25;                       +
 3 c _vat numeric := 0.125;                      +
                                                 +
 5 c IF amount < 100 THEN                        +
 5 c RETURN amount * (1 + _vat);                 +
                                                 +
 6 -     RETURN amount;                          +
 6 -                                             +
                                                 +
 7 - ELSE                                        +
 7 -                                             +
                                                 +
 8 -     RETURN amount * (1 + _vat);             +
 8 -                                             +
                                                 +
 9 - END IF;                                     +
 9 -                                             +
                                                 +
                                                 +
                                                 +
 MD5 of changes: 162d4dcc113345c71f6c9bc4448534aa
(1 row)

Step 2: Deploy

postgres=# SELECT deploy($DEP$
postgres$# CREATE OR REPLACE FUNCTION calc_value_added_tax(amount numeric) RETURNS NUMERIC AS $$
postgres$# DECLARE
postgres$# _vat numeric := 0.125;
postgres$# BEGIN
postgres$# RETURN amount * (1 + _vat);
postgres$# END;
postgres$# $$ LANGUAGE plpgsql IMMUTABLE;
postgres$# $DEP$, '162d4dcc113345c71f6c9bc4448534aa');
