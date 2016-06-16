# Use Ubuntu as the OS and bash
FROM ubuntu:14.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

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

# Setup a volume mount that Apache can recognize
RUN sudo mkdir -p /var/www/html
RUN sudo mv /twinblast/www/* /var/www/html/.

VOLUME ["/var/www/html"]
