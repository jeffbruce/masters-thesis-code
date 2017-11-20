# INITIALIZE
#################################
options(contrasts = c("contr.sum","contr.poly"))
library(car)
library(ez)
library(afex) 
library(xtable)  
library(lattice)
library(lme4)
library(ggplot2)


# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013")
sddata <- read.csv("diary_adjustment_summary_data.csv")

ezANOVA(data=sddata, dv=score, wid=snum, within=.(HA,cond,situation),type=1,detailed=TRUE)