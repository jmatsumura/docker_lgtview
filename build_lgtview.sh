#!/bin/bash

# First prompt the user for whether they want to add
# password protection for MySQL. 
echo -n "Would you like to add a password for the root MySQL user? Please enter 'yes' or 'no': "
read response 
if [ "$response" = 'yes' ]; then
	echo -ne "\nPlease enter the desired password for the root MySQL user: "
	read -s password
	echo -ne "\nPlease re-enter the password: "
	read -s password_confirm

	while [ "$password" != "$password_confirm" ]; do

		echo -ne "\nPasswords do not match. Please re-enter the password: "
		read -s password_confirm

	done

	echo -ne "\nNow setting a root password for MySQL. View the docker-compose.yml file if you lose this password."
	sed -i "26s/ALLOW_EMPTY_PASSWORD: 1/ROOT_PASSWORD: $password_confirm/" ./docker-compose.yml
	echo -e "\nDone setting root password for MySQL."
fi

echo "Going to build and run the Docker containers now......"
# Now, establish the following Docker containers:
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
echo "Docker containers done building and ready to go!"
#sleep 10

# Ask the user whether they want their site to be password protected
echo -ne "\nWould you like to add password protection for viewing access to the LGTview site? Please enter 'yes' or 'no': "
read response 
if [ "$response" = 'yes' ]; then

		echo -ne "\nPlease enter the desired username for accessing LGTview: "
		read username
		echo -ne "\nPlease enter the desired password for the username $username: "
		read -s password
		echo -ne "\nPlease re-enter the password: "
		read -s password_confirm

	while [ "$password" != "$password_confirm" ]; do

		echo -ne "\nPasswords do not match. Please re-enter the password: "
		read -s password_confirm

	done

	echo -e "\nAdding username and password protection to the site, just one moment..."

	# Go into the Apache container and configure for passwords. Here, respond to the
	# two interactive prompts using the supplied passwords.
	docker exec -it dockerlgtview_LGTview_1 (printf '%s\n%s' "$password_confirm" "$password_confirm" && cat) | sudo htpasswd -c /etc/apache2/.htpasswd "$username"

	# Now configure the necessary Apache confs to accommodate this protected setup.
	docker exec -it dockerlgtview_LGTview_1 sed -i '178s/None/All/' /etc/apache2/apache2.conf
	docker exec -it dockerlgtview_LGTview_1 printf '%s\n%s\n%s\n%s' 'AuthType Basic' 'AuthName "Restricted Content"' 'AuthUserFile /etc/apache2/.htpasswd' 'Require valid-user' >> /var/www/html/.htaccess

	# Restart the Apache container with this new configuration
	docker kill -signal="USR1" dockerlgtview_LGTview_1

	echo "Login requirement added. Please be sure to save this information somewhere so that you do not lose access to the site."
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
