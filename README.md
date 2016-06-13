# docker_lgtview
This repository houses multiple Dockerfiles that can be used to build an example 
and ultimately customizable instance of LGTview.

There will be multiple containers/images spanning the various components of LGTview that
must be combined using docker-compose and the docker-compose.yml file. Below is a 
brief rundown with more details to be found in the comments of the docker-compose.yml
file. 

Containers:

./LGTview - houses the LGTview specific scripts to view the data on the server
as well as those to scripts needed to format and load a custom dataset 

./TwinBLAST - contains the scripts and annotation DB for the TwinBLAST interface
that can be reached through LGTview

./krona - houses code to generate the interactive krona plots for the main interface
of LGTview

./Apache - this container houses the web server front-end along with the ExtJS 
dependencies 

Images:

MongoDB - houses the backend DB that LGTview pulls from

# TO BE ADDED WITH FUTURE UPDATES
Containers:

./Circleator - similar to R, this container houses the scripts necessary to run and 
generate circular plots of genome-associated data

Images: 

R - the R statistical software package is contained here to aid in the generation
of graphics
