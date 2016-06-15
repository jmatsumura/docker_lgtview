# Use Ubuntu as the OS
FROM ubuntu:14.04

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

# Install Apache and git
RUN sudo apt-get update && sudo apt-get install -y apache2 \
							git \
							wget

# Make the custom conf directory available to Apache
RUN sudo mkdir /etc/apache2/conf.d \
		/export/lgt/indexes \
		/export/lgt/files \
		/var/www/html/conf \
		/tmp

# Get the pre-configured conf file
RUN sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/apache2.conf -O /etc/apache2/apache2.conf 

# Now pull any other conf files that need to set web environmental variables or
# be web-accessible by scripts
# 1. Conf for TwinBLAST
RUN sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/twinblast.conf -O /etc/apache2/conf.d/twinblast.conf 

# 2. Conf for TwinBLAST DB access
RUN sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/curation_db.ini -O /var/www/html/conf/curation_db.ini

# Start the Apache server
RUN sudo service apache2 start 

# Place ExtJS library accessible to webserver
RUN sudo git clone github.com/probonogeek/extjs.git /var/www/html/ext-4.1.1a
