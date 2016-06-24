#!/bin/bash

# First configure MySQL with or without a password depending on what the user wants.
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
docker-compose up -d

echo "Docker containers done building and ready to go! Please follow the rest of the installation prompts."

# Before attempting to interact with the containers, give them
# a few seconds to truly initiate running and be accessible.
sleep 5

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
	docker exec -it dockerlgtview_LGTview_1 (printf '%s\n%s' "$password_confirm" "$password_confirm" && cat) \
		 | sudo htpasswd -c /etc/apache2/.htpasswd "$username"

	# Now configure the necessary Apache confs to accommodate this protected setup.
	docker exec -it dockerlgtview_LGTview_1 sudo sed -i '178s/None/All/' /etc/apache2/apache2.conf
	docker exec -it dockerlgtview_LGTview_1 sudo printf '%s\n%s\n%s\n%s' \
		'AuthType Basic' \
		'AuthName "Restricted Content"' \
		'AuthUserFile /etc/apache2/.htpasswd' \
		'Require valid-user' \
		>> /var/www/html/.htaccess

	# Restart the Apache container with this new configuration
	docker kill -signal="USR1" dockerlgtview_LGTview_1

	echo "Login requirement added. Please be sure to save this information somewhere so that you do not lose access to the site."
fi

# Can't think of a reason a user would not want https so just add
# it in as default instead of prompting for it. 
docker exec -it dockerlgtview_LGTview_1 sudo a2enmod ssl
docker kill -signal="USR1" dockerlgtview_LGTview_1
docker exec -it dockerlgtview_LGTview_1 sudo mkdir /etc/apache2/ssl
echo "Please answer the following in order to setup SSL (https) for the site."
echo -ne "\nCountry Name (2 letter code) [US]: "
read country
echo -ne "\nState or Province Name (full name) [New York]: "
read state
echo -ne "\nLocality Name (eg, city) [New York City]: "
read city
echo -ne "\nOrganization Name (eg, company) [University of Maryland]: "
read organization
echo -ne "\nOrganizational Unit Name (eg, section) [Institute for Genome Sciences]: "
read division
echo -ne "\nYour email [best_email@domain.com]: "
read email
docker exec -it dockerlgtview_LGTview_1 printf '\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
	"$country" \
	"$state" \
	"$city" \
	"$organization" \
	"$division" \
	"172.18.0.1:8080" \
	"$email" \
	&& cat | sudo openssl req -x509 -nodes -days 1460 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.crt

docker exec -it dockerlgtview_LGTview_1 sudo sed -i '32s@/etc/ssl/certs/ssl-cert-snakeoil.pem@/etc/apache2/ssl/apache.crt@' /etc/apache2/sites-available/default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 sudo sed -i '33s@/etc/ssl/private/ssl-cert-snakeoil.key@/etc/apache2/ssl/apache.key@' /etc/apache2/sites-available/default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 sudo sed -i "3s/webmaster@localhost/$email/" /etc/apache2/sites-available/default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 sudo sed -i "3a\n\t\tServerName 172.18.0.1:8080" /etc/apache2/sites-available/default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 sudo sed -i "4a\n\t\tServerAlias localhost:8080" /etc/apache2/sites-available/default-ssl.conf

docker exec -it dockerlgtview_LGTview_1 sudo a2ensite default-ssl.conf
docker kill -signal="USR1" dockerlgtview_LGTview_1

# Make sure the MySQL server container is up and running
UP=$(docker ps -a | grep 'mysql' | grep 'Up' | wc -l);
while [ "$UP" -ne 1 ]; do
	UP=$(docker ps -a | grep 'mysql' | grep 'Up' | wc -l);
	sleep 5
done

# Now populate the MySQL database to prepare for curation via TwinBLAST
docker exec -it dockerlgtview_LGTview_1 perl /lgtview/bin/init_db.pl

# Make sure the MongoDB server container is up and running
UP1=$(docker ps -a | grep 'mongo:2.6' | grep 'Up' | wc -l);
while [ "$UP1" -ne 1 ]; do
	UP1=$(docker ps -a | grep 'mongo:2.6' | grep 'Up' | wc -l);
	sleep 5
done

# Now initialize MongoDB. Need the dump taken from revan in order to accommodate
# the necessary taxonomic assignments. 
#docker exec -it dockerlgtview_LGTview_1 perl /lgtview/bin/init_mongodb.pl
