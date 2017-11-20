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
options(digits=3)


# NCSTUDY1 COMPLETE (covariates are likely uninteresting -- within subjects study)
###################################################################################################################

# READ IN DATA - NCStudy1 Data
#################################
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy1 Data - Nov 2 2012")
qualdata <- read.csv("music_quality_summary_data.csv")

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("NCStudy1_covariates.csv")
qualcov <- cbind(qualdata,covdata)

# investigate covariates (NewLRPTA, satis, worstthresh, age)
xyplot(score ~ worstthresh, 
       groups = HA, 
       data = qualcov,  
       panel = function(x, y, ...) {
         panel.superpose(x, y, ...,
                         panel.groups = function(x,y, col, col.symbol, ...) {
                           panel.xyplot(x, y, col=col.symbol, ...)
                           panel.abline(lm(y~x), col.line=col.symbol)
                         }
         )
         panel.abline(lm(y~x))
       },
       auto.key = list(title='HA', space='right')
)
model1 <- lm(score ~ worstthresh, data=qualcov)
anova(model1)

model1 <- aov(score ~ HA*quality + Error(snum/HA*quality), data=qualcov)
summary(model1)

model1 <- ezANOVA(qualcov, score, snum, within=list(HA,quality))
print(model1)


# NCSTUDY2 HALFWAY (covariates = age, worstthresh, PTA, wdquiet)
# the groups mainly only differ in wdquiet, and worstthresh but worstthresh seems arbitrary
###################################################################################################################

# TYPE I ANALYSIS USING R STANDARD METHODS
#################################

setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - March 28 2013")
qualdata <- read.csv("NC2half_music_quality_summary_data.csv")

covdata <- read.csv("NC2half_covariates.csv")
qualcov <- cbind(qualdata,covdata)

# investigate covariates (PTA, wdquiet, worstthresh, age)
xyplot(score ~ wdquiet, 
       groups = HA, 
       data = qualcov,  
       panel = function(x, y, ...) {
         panel.superpose(x, y, ...,
                         panel.groups = function(x,y, col, col.symbol, ...) {
                           panel.xyplot(x, y, col=col.symbol, ...)
                           panel.abline(lm(y~x), col.line=col.symbol)
                         }
         )
         panel.abline(lm(y~x))
       },
       auto.key = list(title='HA', space='right')
)
model1 <- lm(score ~ wdquiet, data=qualcov)
anova(model1)

# REGULAR ANOVA
model1 <- aov(score ~ HA*quality + Error(snum/quality), data=qualcov)
summary(model1)

# ANCOVA
model1 <- aov(score ~ age*HA*quality + Error(snum/quality), data=qualcov)
summary(model1)


# NCSTUDY2 (correlations = age, PTA, highloss, lowloss, midloss, wdquiet)
###################################################################################################################

setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013")
qualdata <- read.csv("quality_summary_data.csv")

covdata <- read.csv("NC2half_covariates.csv")
qualcov <- cbind(qualdata,covdata)

# investigate covariates (PTA, wdquiet, worstthresh, age)
xyplot(score ~ wdquiet, 
       groups = HA, 
       data = qualcov,  
       panel = function(x, y, ...) {
         panel.superpose(x, y, ...,
                         panel.groups = function(x,y, col, col.symbol, ...) {
                           panel.xyplot(x, y, col=col.symbol, ...)
                           panel.abline(lm(y~x), col.line=col.symbol)
                         }
         )
         panel.abline(lm(y~x))
       },
       auto.key = list(title='HA', space='right')
)
model1 <- lm(score ~ wdquiet, data=qualcov)
anova(model1)

# REGULAR ANOVA
model1 <- aov(score ~ HA*cond + Error(snum/HA*cond), data=qualdata)
summary(model1)

# ezANOVA
e<-ezANOVA(data=qualdata, dv=score, wid=snum, within=.(HA,cond),type=3,detailed=TRUE)

