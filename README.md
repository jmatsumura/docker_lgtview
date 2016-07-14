# docker_lgtview
This repository houses multiple Dockerfiles that can be used to build an example 
and ultimately customizable instance of LGTview. This pulls the source LGTView code from 
https://github.com/jmatsumura/lgtview

There will be multiple containers/images spanning the various components of LGTview that
must be combined using docker-compose and the docker-compose.yml file. Below is a 
brief rundown with more details to be found in the comments of the docker-compose.yml
file. 

Both DBs, (MongoDB for LGTview & MySQL for TwinBLAST), are more simply imported 
as preset images from Docker hub. 

Containers:

./LGTview - Houses Apache and ExtJS along with the following pieces of code that comprise 
all the functionality present in LGTview:

	- TwinBLAST - contains the scripts for the TwinBLAST interface that is reached through 
	LGTview

	- krona - houses code to generate the interactive krona plots for the main interface
	of LGTview

Images: 

MySQL
MongoDB

# TO BE ADDED WITH FUTURE UPDATES
Additional repos to be incorporated:

* Circleator - this code houses the scripts necessary to run and generate circular
plots of genome-associated data

Images: 

* R - the R statistical software package is contained here to aid in the generation
of graphics like a heatmap
