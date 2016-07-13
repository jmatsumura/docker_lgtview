# Use Ubuntu as the OS and bash
FROM ubuntu:14.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

# Install Apache and git
RUN sudo apt-get update && sudo apt-get install -y apache2 \
							apache2-utils \
							git \
							wget \
							openssl 

# Make the custom conf/ssl directories available to Apache
RUN sudo mkdir /etc/apache2/{conf.d,ssl} \
				/var/www/html/{conf,cgi,tmp} \
				&& sudo mkdir -p /export/lgt/{files,indexes} \
				&& sudo chmod 777 /var/www/html/tmp \
				&& sudo chmod 777 /export/lgt/indexes

# Add in FQDN for SSL
RUN sudo echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
RUN sudo a2enconf fqdn

# Get the pre-configured conf files
RUN sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/apache2.conf -O /etc/apache2/apache2.conf \
		&& sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/twinblast.conf -O /etc/apache2/conf.d/twinblast.conf \
		&& sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/curation_db.ini -O /var/www/html/conf/curation_db.ini \
		&& sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/mongo_config.ini -O /var/www/html/conf/mongo_config.ini

# Place ExtJS library accessible to webserver
RUN sudo git clone https://github.com/NewbridgeGreen/extjs.git /var/www/html/ext-4.1.0

# Next section will obtain all the dependencies for LGTview / TwinBLAST functionality. 

# Install Perl and base MySQL so that the perl libs that
# depend on a MySQL presence are installed properly. This
# may pose an issue later but for now, try keep separate containers
# for this and for MySQL.
RUN sudo apt-get update && sudo apt-get install -y perl \
                            build-essential \
                            apt-utils \
                            gcc-multilib \
                            libgd-gd2-perl \
                            libmysqlclient-dev \
                            cpanminus \
							bioperl

# Install necessary perl dependencies to run TwinBLAST and LGTview
RUN cpanm --force CGI \
    DBI \
    DBD::mysql \
    File::Slurp \
    File::Find \
	File::Path \
    File::Basename \
    Tie::File \
    Digest::MD5 \
    URI::Escape \
    JSON \
    Config::IniFiles \
    POSIX \
    IPC::Open3 \
    Bio::Root::Version \
    Bio::Graphics \ 
    Bio::DB::Taxonomy \ 
    Bio::DB::EUtilities \ 
	Data::Dumper \
	Time::SoFar \
	MongoDB \
	MongoDB::Code \
	Getopt::Long \
	base \
	Cwd \ 
	Pod::Usage

# Enable modules for SSL/redirection and CGI
RUN sudo a2enmod ssl \
	&& sudo a2enmod cgi
RUN sudo git clone https://github.com/jmatsumura/lgtview.git
RUN sudo cp -r /lgtview/www/lgtview/html/* /var/www/html/. && sudo cp -r /lgtview/www/lgtview/cgi/* /var/www/html/cgi/.
RUN sudo cp -r /lgtview/www/twinblast/html/* /var/www/html/. && sudo cp -r /lgtview/www/twinblast/cgi/* /var/www/html/cgi/.

################

# Expose ports and start the Apache server
EXPOSE 443
EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
