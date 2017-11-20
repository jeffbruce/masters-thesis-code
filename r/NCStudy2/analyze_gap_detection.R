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


# READ IN DATA - NCStudy1 Data
#################################
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy1 Data - Nov 2 2012")
gapdata <- read.csv("gap_summary_data.csv")
gapdata$avthresh <- rowMeans(gapdata[,4:6])

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("NCStudy1_covariates.csv")
gapcov <- cbind(gapdata,covdata)

# investigate covariates (NewLRPTA, satis, worstthresh, age)
xyplot(avthresh ~ NewLRPTA, 
       groups = HA, 
       data = gapcov,  
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
model1 <- lm(avthresh ~ NewLRPTA, data=gapcov)
anova(model1)

# ONE WAY ANOVA
#################################
gap.aov <- aov(avthresh ~ HA + Error(snum/HA),data=gapcov)
summary(gap.aov)
ezANOVA(gapcov, avthresh, snum, within=HA, type=3)

# EFFECTS ACROSS SESSIONS
#################################
gap.aov = aov(avthresh ~ session + Error(sname/session), data=gapdata1)
summary(gap.aov)
print(model.tables(mhn.aov,"means"),digits=3)

# EFFECTS WITHIN SESSION
#################################
cweights <- c(-1,0,1)
thresh.mat <- with(gapdata, cbind(thresh1, thresh2, thresh3))
compscores <- thresh.mat %*% cweights
compscores
t.test(compscores)


# NCSTUDY2 HALFWAY (covariates = age, worstthresh, PTA, wdquiet)
# the groups mainly only differ in wdquiet, and worstthresh but worstthresh seems arbitrary
###################################################################################################################

# TYPE I ANALYSIS USING R STANDARD METHODS
#################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - March 28 2013")
gapdata <- read.csv("NC2half_gap_summary_data.csv")
gapdata$avthresh <- rowMeans(gapdata[,4:6])

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("NC2half_covariates.csv")
gapcov <- cbind(gapdata,covdata)

# investigate covariates (PTA, wdquiet, worstthresh, age)
xyplot(avthresh ~ PTA, 
       groups = HA, 
       data = gapcov,  
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
model1 <- lm(avthresh ~ worstthresh + HA + worstthresh:HA, data=gapcov)
anova(model1)

model1 = lm(avthresh ~ HA, data=gapcov)
anova(gapcov2.lm)


# TYPE III ANALYSIS USING DROP1
#################################
drop1(gapcov2.lm, .~., test="F")  # unbalanced data: wdquiet changes from p=0.09 (Type I) to p=0.65 (Type III)!
                                  # the more plausible value I think is p=0.09, Type III violates PoM
                                  # balanced data: wdquiet changes from p=0.12 (Type I) to p=0.55 (Type III)!

# EFFECTS WITHIN SESSION
#################################
cweights <- c(-1,0,1)
thresh.mat <- with(gapdata2, cbind(thresh1, thresh2, thresh3))
compscores <- thresh.mat %*% cweights
compscores
t.test(compscores)


# NCSTUDY2 (correlations = age, PTA, highloss, lowloss, midloss, wdquiet)
###################################################################################################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013")
gapdata <- read.csv("gap_summary_data.csv")
gapdata$avthresh <- rowMeans(gapdata[,4:6])

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("covariates.csv")
gapcov <- cbind(gapdata,covdata)
gapcov <- gapcov[,c(-10,-11)]

# investigate covariates
xyplot(avthresh ~ midloss, 
       groups = HA, 
       data = gapcov,  
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
model1 <- lm(avthresh ~ age, data=gapcov)
anova(model1)

model1 = aov(avthresh ~ HA+Error(snum/HA), data=gapcov)
summary(model1)
print(xtable(model1))

#ges changes a lot between type=1 and type=3
ezANOVA(gapcov, avthresh, snum, within=HA, type=1)

# afex doesn't allow type I for some reason?
aov.car(avthresh ~ Error(snum/HA), data=gapcov, type=2, return="Anova")


# EFFECTS WITHIN SESSION
#################################
cweights <- c(-1,0,1)
thresh.mat <- with(gapcov, cbind(thresh1, thresh2, thresh3))
compscores <- thresh.mat %*% cweights
gapcov$compscores <- compscores
compscores
t.test(compscores)

# EFFECTS ACROSS SESSIONS
#################################
ezANOVA(gapcov, avthresh, snum, within=session, type=1)
