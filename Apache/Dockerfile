# Use Ubuntu as the OS
FROM ubuntu:14.04

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

# Install Apache and git
RUN sudo apt-get update && sudo apt-get install -y apache2 \
							git 

# Get the pre-configured conf file
RUN sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/apache.conf -O /etc/apache2/apache2.conf 

# Start the Apache server
RUN sudo service apache2 start 

# Place ExtJS library accessible to webserver
RUN sudo git clone github.com/probonogeek/extjs.git /var/www/html/ext-4.1.1a
