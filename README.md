# docker_lgtview
This repository houses multiple Dockerfiles that can be used to build an example 
and ultimately customizable instance of LGTview.

There will be multiple containers/images spanning the various components of LGTview that
must be combined using docker-compose and the docker-compose.yml file. Below is a 
brief rundown with more details to be found in the comments of the docker-compose.yml
file. 

Both DBs, (MongoDB for LGTview && MySQL for TwinBLAST), are more simply imported 
as preset images from Docker hub. 

Containers:

./LGTview - houses the LGTview specific scripts to view the data on the server
as well as those to scripts needed to format and load a custom dataset 

./TwinBLAST - contains the scripts and annotation DB for the TwinBLAST interface
that can be reached through LGTview. While not ideal to have two components covered
by one container, this container also houses some MySQL libs necessary for the installation of some of the perl modules which interact with MySQL.

./krona - houses code to generate the interactive krona plots for the main interface
of LGTview

./Apache - this container houses the web server front-end along with the ExtJS 
dependencies 

# TO BE ADDED WITH FUTURE UPDATES
Containers:

./Circleator - similar to R, this container houses the scripts necessary to run and 
generate circular plots of genome-associated data

Images: 

R - the R statistical software package is contained here to aid in the generation
of graphics
