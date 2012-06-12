CREATE LANGUAGE plperlu;
BEGIN;
\i functions/Deploy.sql
\i functions/Diff.sql
\i tables/Deploys.sql
\i views/View_Functions.sql
COMMIT;
