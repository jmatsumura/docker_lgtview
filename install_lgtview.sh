#!/bin/bash

echo -n "----------------------------------------------------------------------------------------------------"
echo -e "\nWelcome to the LGTview installer. Please follow the prompts below that will help configure the security level of the site."

# First configure MySQL with or without a password depending on what the user wants.
echo -n "----------------------------------------------------------------------------------------------------"
echo -ne "\nWould you like to add a password for the root MySQL user? Please enter 'yes' or 'no': "
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
echo "----------------------------------------------------------------------------------------------------"

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

echo "----------------------------------------------------------------------------------------------------"
echo -n "Docker containers done building and ready to go! Please follow the rest of the installation prompts."
echo -ne "\n----------------------------------------------------------------------------------------------------"

# Ask the user whether they want their site to be password protected
echo -ne "\nWould you like to add password protection for viewing access to the LGTview site? Please enter 'yes' or 'no': "
read response 
if [ "$response" = 'yes' ]; then

		echo -ne "Please enter the desired username for accessing LGTview: "
		read username
		echo -ne "Please enter the desired password for the username $username: "
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
	docker exec -it dockerlgtview_LGTview_1 htpasswd -cb /etc/apache2/.htpasswd "$username" "$password_confirm"

	# Now configure the necessary Apache confs to accommodate this protected setup.
	docker exec -it dockerlgtview_LGTview_1 sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
	# Just in case the installer has failed, clear the file and start anew
	rm ./.htaccess
	printf '%s\n%s\n%s\n%s' 'AuthType Basic' 'AuthName "Restricted Content"' 'AuthUserFile /etc/apache2/.htpasswd' 'Require valid-user' >> ./.htaccess
	docker cp ./.htaccess dockerlgtview_LGTview_1:/var/www/html/.htaccess

	# Restart the Apache container with this new configuration
	docker exec -it dockerlgtview_LGTview_1 /etc/init.d/apache2 reload
	echo "Login requirement added. Please be sure to save this information somewhere so that you do not lose access to the site."
fi

echo -e "----------------------------------------------------------------------------------------------------"
docker kill --signal="USR1" dockerlgtview_LGTview_1 /etc/init.d/apache2
#docker exec -it dockerlgtview_LGTview_1 a2enmod ssl
#docker exec -it dockerlgtview_LGTview_1 /etc/init.d/apache2 reload

# Can't think of a reason a user would not want https so just add
# it in as default instead of prompting for it. 
echo -n "Please answer the following in order to setup SSL (https) for the site."
echo -ne "\nCountry Name (2 letter code) [US]: "
read country
echo -ne "State or Province Name (full name) [New York]: "
read state
echo -ne "Locality Name (eg, city) [New York City]: "
read city
echo -ne "Organization Name (eg, company) [University of Maryland]: "
read organization
echo -ne "Organizational Unit Name (eg, section) [Institute for Genome Sciences]: "
read division
echo -ne "Email for setup contact [the_best_email@domain.com]: "
read email
docker exec -it dockerlgtview_LGTview_1 openssl req -x509 -nodes -days 1460 -newkey rsa:2048 \
	-keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt \
	-subj "/C=$country/ST=$statei/L=$city/O=$organization/OU=$division/CA=TRUE/CN=localhost"

# Modify the confs to use the newly generated SSL cert+key
docker exec -it dockerlgtview_LGTview_1 sed -i '32s@/etc/ssl/certs/ssl-cert-snakeoil.pem@/etc/apache2/ssl/apache.crt@' /etc/apache2/sites-available/default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 sed -i '33s@/etc/ssl/private/ssl-cert-snakeoil.key@/etc/apache2/ssl/apache.key@' /etc/apache2/sites-available/default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 sed -i "3s/webmaster@localhost/$email/" /etc/apache2/sites-available/default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 sed -i "3a\\\t\tServerName localhost:443" /etc/apache2/sites-available/default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 sed -i "4a\\\t\tServerAlias lgtview" /etc/apache2/sites-available/default-ssl.conf

# Set this new SSL conf and restart Apache one last time. SSL should now be enabled
docker exec -it dockerlgtview_LGTview_1 a2ensite default-ssl.conf
docker exec -it dockerlgtview_LGTview_1 /etc/init.d/apache2 reload
echo -ne "SSL now implemented (access site through https)."
echo -e "\n----------------------------------------------------------------------------------------------------"

# Make sure the MySQL server container is up and running
UP=$(docker ps -a | grep 'mysql' | grep 'Up' | wc -l);
while [ "$UP" -ne 1 ]; do
	UP=$(docker ps -a | grep 'mysql' | grep 'Up' | wc -l);
	sleep 5
done

# Now populate the MySQL database to prepare for curation via TwinBLAST
#docker exec -it dockerlgtview_LGTview_1 perl /lgtview/bin/init_db.pl

# Make sure the MongoDB server container is up and running
UP1=$(docker ps -a | grep 'mongo:2.6' | grep 'Up' | wc -l);
while [ "$UP1" -ne 1 ]; do
	UP1=$(docker ps -a | grep 'mongo:2.6' | grep 'Up' | wc -l);
	sleep 5
done

# Now initialize MongoDB. Need the dump taken from revan in order to accommodate
# the necessary taxonomic assignments. 
#docker exec -it dockerlgtview_LGTview_1 perl /lgtview/bin/init_mongodb.pl
