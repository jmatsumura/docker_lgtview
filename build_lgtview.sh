#!/bin/bash

# First, establish the following containers:
# 1. dockerlgtview_LGTview_1
#  - Houses the Apache server and LGTview related code
# 2. dockerlgtview_mongo_1
#  - Houses the MongoDB server
# 3. dockerlgtview_mongodata_1
#  - A container to establish persistent MongoDB data
# 4. dockerlgtview_MySQL_1
#  - Houses the MySQL server
docker-compose up -d

# Before attempting to interact with the containers, give them
# a few seconds to truly initiate running and be accessible.
sleep 10

# Make sure the MySQL server can be reached
UP=$(docker ps -a | grep 'mysql' | grep 'Up' | wc -l);
while [ "$UP" -ne 1 ]; do
	UP=$(docker ps -a | grep 'mysql' | grep 'Up' | wc -l);
	sleep 5
done

# Now populate the MySQL database to prepare for curation via TwinBLAST
docker exec -it dockerlgtview_LGTview_1 perl /lgtview/bin/init_db.pl
