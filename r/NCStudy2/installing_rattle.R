#installing rattle to enable R to have a data mining toolbar
#need to get Glade/GTK+ for windows before running the following commands
#can obtain it from here: http://sourceforge.net/projects/gladewin32/?source=dlp
#installation instructions for rattle are here:
#  http://datamining.togaware.com/survivor/Installation_Details.html

install.packages("RGtk2")
library(RGtk2)

install.packages("rattle", dependencies=c("Depends", "Suggests"))
rattle()