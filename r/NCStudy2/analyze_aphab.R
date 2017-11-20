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
#setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/R Scripts/NCStudy2")
#source("print_ezANOVA.R")
options(digits=3)


# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013")
aphabdata <- read.csv("aphab_aided_summary_data.csv")

e<-ezANOVA(data=aphabdata, dv=score, wid=snum, within=.(HA,subscale),type=3,detailed=TRUE)
#significant HA*subscale effect, after correction for sphericity
#need to examine simple effects at each subscale level

ECdata <- subset(aphabdata,subscale=="EC")
ezANOVA(data=ECdata, dv=score, wid=snum, within=HA,type=3,detailed=TRUE)

RVdata <- subset(aphabdata,subscale=="RV")
ezANOVA(data=RVdata, dv=score, wid=snum, within=HA,type=3,detailed=TRUE)

BNdata <- subset(aphabdata,subscale=="BN")
ezANOVA(data=BNdata, dv=score, wid=snum, within=HA,type=3,detailed=TRUE)

AVdata <- subset(aphabdata,subscale=="AV")
ezANOVA(data=AVdata, dv=score, wid=snum, within=HA,type=3,detailed=TRUE)