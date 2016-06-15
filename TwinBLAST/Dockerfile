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

# Startup MySQL
RUN sudo service mysql start
RUN sudo chmod 777 /var/run/mysqld/
RUN sudo ln -s /var/run/mysqld/mysql.sock /tmp/mysql.sock

# Configure MySQL. Combined to one line so that
# multiple images are not made for this step.
RUN sudo mysql -u root -h localhost -e "CREATE USER 'twinblast'@'localhost' IDENTIFIED BY 'twinblast';GRANT ALL on twinblast.* TO 'twinblast'@'localhost';CREATE DATABASE twinblast;CREATE TABLE twinblast.curation(seq_id VARCHAR(100), cv_id INT, PRIMARY KEY(seq_id));CREATE TABLE twinblast.cv(name VARCHAR(100));ALTER TABLE twinblast.cv ADD COLUMN id INT NOT NULL AUTO_INCREMENT FIRST, ADD primary KEY id(id); ALTER TABLE twinblast.cv ADD UNIQUE(name);INSERT INTO twinblast.cv (name) VALUES ('yes');INSERT INTO twinblast.cv (name) VALUES ('no');INSERT INTO twinblast.cv (name) VALUES ('maybe');"

# Install necessary perl dependencies
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
