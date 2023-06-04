#!/bin/bash

# This script will be copied onto
# the EC2 instance and schedules as
# a cron job.

# Extract the DB container name
DB_CONTAINER_NAME="$(sudo docker ps -aqf 'name=db')"

SQL_SCRIPT='SELECT table_schema "DB Name", Round(Sum(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB" FROM information_schema.tables GROUP BY table_schema ORDER BY "DB Size in MB" DESC;'

# store SQL in local file
echo $SQL_SCRIPT > sql_script.txt

# Copy script to the DB container
# and delete it from the host.
sudo docker cp ./sql_script.txt "$DB_CONTAINER_NAME":/sql_script.txt
rm sql_script.txt

# Execute the SQL command in the DB container
# and delete the script when done
sudo docker exec -i "$DB_CONTAINER_NAME" sh -c 'mysql -uroot -prootpass -e "$(cat ./sql_script.txt)" > DB_size.log'
sudo docker exec -i "$DB_CONTAINER_NAME" sh -c 'rm ./sql_script.txt'

# Copy db log file from the DB container
# to the host and delete it from the container
sudo docker cp "$DB_CONTAINER_NAME":/DB_size.log ./DB_size.log
sudo docker exec -i "$DB_CONTAINER_NAME" sh -c 'rm ./DB_size.log'
