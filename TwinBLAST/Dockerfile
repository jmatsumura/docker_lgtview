# Use Ubuntu as the OS and bash
FROM ubuntu:14.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

# Install Perl AND MySQL (for now, moving MySQL to separate 
# container would be ideal later). Only in the same one
# since some perl dependencies depend on MySQL files present.
RUN sudo apt-get update && sudo apt-get install -y perl \
							build-essential \
							apt-utils \
							gcc-multilib \
							libgd-gd2-perl \
							mysql-server \
							libmysqlclient-dev \
							cpanminus \
							git

# Startup MySQL. Configure the DB so that it's ready for the
# TwinBLAST interface.
RUN /bin/bash -c 'sudo service mysql start ;' \
						sudo mysql -u root -h localhost -e "CREATE USER 'twinblast'@'localhost' IDENTIFIED BY 'twinblast';" \
					    "CREATE DATABASE twinblast;" \
					    "GRANT ALL on twinblast.* TO 'twinblast'@'localhost';" \
						"CREATE TABLE twinblast.curation(seq_id VARCHAR(100), cv_id INT, PRIMARY KEY(seq_id));" \
						"ALTER TABLE twinblast.cv ADD COLUMN id INT NOT NULL AUTO_INCREMEMNT FIRST, ADD PRIMARY KEY id(id);" \
						"ALTER TABLE twinblast.cv ADD UNIQUE(name);" \
						"INSERT INTO twinblast.cv (name) VALUES ('yes');" \
						"INSERT INTO twinblast.cv (name) VALUES ('no');" \
						"INSERT INTO twinblast.cv (name) VALUES ('maybe');" 

# Install necessary perl dependencies
#RUN cpanm --force CGI \
#	DBI \
#	DBD::mysql \
#	File::Slurp \
#	Tie::File \
#	File::Basename \
#	Digest::MD5 \
#	URI::Escape \
#	JSON \
#	Config::IniFiles \
#	POSIX \
#	IPC::Open3 \
#	Bio::Root::Version \
#	Bio::Graphics

# Get the TwinBLAST code
#RUN sudo git clone https://github.com/IGS/twinblast.git
