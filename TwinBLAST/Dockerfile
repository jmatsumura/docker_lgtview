# Use Ubuntu as the OS
FROM ubuntu:14.04

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

# Install Perl AND MySQL (for now, moving MySQL later)
RUN sudo apt-get update && sudo apt-get install -y perl \
							build-essential \
							apt-utils \
							gcc-multilib \
							libgd-gd2-perl \
							mysql-server \
							libmysqlclient-dev \
							cpanminus \
							git

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
