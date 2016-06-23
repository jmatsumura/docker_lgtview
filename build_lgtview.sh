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

# Now populate the MySQL database to prepare for
# curation via TwinBLAST
docker exec -it dockerlgtview_LGTview_1 perl /lgtview/bin/init_db.pl
