# Use Ubuntu as the OS and bash
FROM ubuntu:14.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

# Establish TwinBLAST user
RUN sudo groupadd -r twinblast && useradd -r -g twinblast twinblast

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
							cpanminus \
							git

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

# Get the TwinBLAST code
RUN sudo git clone https://github.com/IGS/twinblast.git

RUN sudo mkdir -p /var/www && sudo mv /twinblast/www/html /var/www/html && sudo mv /twinblast/www/cgi /var/www/cgi
RUN sudo chown -R twinblast:twinblast /var/www && sudo chmod -R 777 /var/www
VOLUME /var/www/html
VOLUME /var/www/cgi
