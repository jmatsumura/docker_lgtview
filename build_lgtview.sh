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
#docker-compose up -d

# Before attempting to interact with the containers, give them
# a few seconds to truly initiate running and be accessible.
#sleep 10

# Ask the user whether they want their site to be password protected
echo -n "Would you like to add password protection to the LGTview site? Please enter 'yes' or 'no': "
read response 
if [ "$response" = 'yes' ]; then

		echo -ne "Please enter the desired username for accessing LGTview: "
		read username
		echo -ne "\nPlease enter the desired password for the username $username: "
		read -s password
		echo -ne "\nPlease re-enter the desired password: "
		read -s password_confirm

	while [ "$password" != "$password_confirm" ]; do

		echo -ne "\nPasswords do not match. Please re-enter the password: "
		read -s password_confirm

	done

	echo -ne "\nAdding username and password protection to the site, just one moment..."

	# Go into the Apache container and configure for passwords
	docker exec -it dockerlgtview_LGTview_1 "$password_confirm\\n$password_confirm" | sudo htpasswd -c /etc/apache2/.htpasswd "$username"
	docker exec -it dockerlgtview_LGTview_1 sed -i '178s/None/All/' /etc/apache2/apache2.conf
	# Restart the Apache container with this new configuration
	docker kill -signal="USR1" dockerlgtview_LGTview_1

	echo -ne "\nLogin requirement added. Please save this information somewhere so that you do not lose access to the site.\n"
fi


# Make sure the MySQL server container is up and running
#UP=$(docker ps -a | grep 'mysql' | grep 'Up' | wc -l);
#while [ "$UP" -ne 1 ]; do
#	UP=$(docker ps -a | grep 'mysql' | grep 'Up' | wc -l);
#	sleep 5
#done

# Now populate the MySQL database to prepare for curation via TwinBLAST
#docker exec -it dockerlgtview_LGTview_1 perl /lgtview/bin/init_db.pl

# Make sure the MongoDB server container is up and running
#UP1=$(docker ps -a | grep 'mongo:2.6' | grep 'Up' | wc -l);
#while [ "$UP1" -ne 1 ]; do
#	UP1=$(docker ps -a | grep 'mongo:2.6' | grep 'Up' | wc -l);
#	sleep 5
#done

# Now dump the data taken from Revan into the DB so that it's ready to load 
#docker exec -it dockerlgtview_LGTview_1 perl /lgtview/bin/init_mongodb.pl
