# Use Ubuntu as the OS and bash
FROM ubuntu:14.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER James Matsumura (jmatsumura@som.umaryland.edu)

# Install Apache and git
RUN sudo apt-get update && sudo apt-get install -y git

# Get the TwinBLAST code
RUN sudo git clone https://github.com/IGS/twinblast.git

# Make this code accesible for manipulation/use by the server
VOLUME /twinblast/www
