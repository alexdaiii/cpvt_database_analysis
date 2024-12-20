# bin/bash

TODAY=`date +%Y%m%d`

# Load environment variables
user=$POSTGRES_USER
password=$POSTGRES_PASSWORD
dbname=postgres
# Select the alembic version from public.alembic_version;
ALEMBIC_VERSION=$(PGPASSWORD=$password psql -U $user -h localhost -p 5432 -d $dbname -t -c "SELECT version_num FROM alembic_version")
ALEMBIC_VERSION_FILE=$(echo $ALEMBIC_VERSION | sed 's/[^a-zA-Z0-9_]//g')

echo "Alembic version: $ALEMBIC_VERSION_FILE"

# save the users
pg_dumpall --globals-only -U $user > /home/00_"$TODAY"_globals.sql

# Dump the database
pg_dump -U $user -h localhost -p 5432 -d $dbname | gzip > /home/"$TODAY"-"$ALEMBIC_VERSION_FILE".sql.gz
