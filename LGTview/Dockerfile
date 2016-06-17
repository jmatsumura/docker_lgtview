# Use Ubuntu as the OS and bash
FROM ubuntu:14.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

# Install Apache and git
RUN sudo apt-get update && sudo apt-get install -y apache2 \
							git \
							wget

# Make the custom conf directory available to Apache
RUN sudo mkdir /etc/apache2/conf.d \
				/var/www/html/conf \
				&& sudo mkdir -p /export/lgt/{files,indexes}

# Get the pre-configured conf files
RUN sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/apache2.conf -O /etc/apache2/apache2.conf \
		&& sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/twinblast.conf -O /etc/apache2/conf.d/twinblast.conf \
		&& sudo wget https://raw.githubusercontent.com/jmatsumura/docker_lgtview/master/misc/curation_db.ini -O /var/www/html/conf/curation_db.ini

# Place ExtJS library accessible to webserver
RUN sudo git clone https://github.com/probonogeek/extjs.git /var/www/html/ext-4.1.1a

# Next few sections will have a few images (each section will account 
# for dependencies for a particular program).

### TwinBLAST ###

# Install Perl and base MySQL so that the perl libs that
# depend on a MySQL presence are installed properly. This
# may pose an issue later but for now, try keep separate containers
# for this and for MySQL.
RUN sudo apt-get update && sudo apt-get install -y perl \
                            build-essential \
                            apt-utils \
                            gcc-multilib \
                            libgd-gd2-perl \
                            mysql-server \
                            libmysqlclient-dev \
                            cpanminus

# Install necessary perl dependencies to run TwinBLAST
RUN cpanm --force CGI \
    DBI \
    DBD::mysql \
    File::Slurp \
    Tie::File \
    File::Basename \
    Digest::MD5 \
    URI::Escape \
    JSON \
    Config::IniFiles \
    POSIX \
    IPC::Open3 \
    Bio::Root::Version \
    Bio::Graphics

RUN sudo git clone https://github.com/IGS/twinblast.git
RUN sudo mv /twinblast/www/html/* /var/www/html/. && sudo mv /twinblast/www/cgi /var/www

################

# Start the Apache server
EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
