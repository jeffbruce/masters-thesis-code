# INITIALIZE
#################################
options(contrasts = c("contr.sum","contr.poly"))
library(car)  # John Fox Anova code
library(ez)  # ezANOVA is a wrapper for the car::Anova function, easier to use
             # unfortunately it doesn't offer the option of specifying covariates
library(afex)  # inspired by the ez package, and does offer the option of specifying covariates
               # also gives the option of printing a nice anova table
               # also is a wrapper for the car::Anova function
               # problem with this one is it assumes there is an interaction between the covariate
               # and factor of interest
library(xtable)  # can use the output from afex to create LaTeX code to input a nice looking
                 # anova table


# NCSTUDY1 COMPLETE (covariates are likely uninteresting -- within subjects study)
###################################################################################################################

# READ IN DATA - NCStudy1 Data
#################################
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy1 Data - Nov 2 2012")
vcvdata <- read.csv("vcv_summary_data.csv")
vcvdata$pcentcor <- vcvdata$cor*100


# COVARIATES
#################################
covdata <- read.csv("NCStudy1_covariates.csv")
vcvcov <- cbind(vcvdata,covdata)

# investigate covariates (NewLRPTA, satis, worstthresh, age)
xyplot(pcentcor ~ satis, 
       groups = HA, 
       data = vcvcov,  
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
model1 <- lm(pcentcor ~ satis, data=vcvcov)
anova(model1)


# ANOVA
#################################
vcv.aov <- aov(pcentcor ~ HA*cond + Error(snum/HA*cond),data=vcvcov)
summary(vcv.aov)
ezANOVA(vcvdata, pcentcor, snum, within=list(HA,cond), type=3)


# EFFECTS ACROSS SESSIONS
#################################
vcv.aov = aov(pcentcor ~ session + Error(snum/session), data=vcvdata)
summary(vcv.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# NCSTUDY2 HALFWAY (covariates = age, worstthresh, PTA, wdquiet)
# the groups mainly only differ in wdquiet, and worstthresh but worstthresh seems arbitrary
###################################################################################################################

# TYPE I ANALYSIS USING R STANDARD METHODS
#################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - March 28 2013")
vcvdata <- read.csv("NC2half_vcv_summary_data.csv")
vcvdata$pcentcor <- vcvdata$cor*100

# read in covariates
covdata <- read.csv("NC2half_covariates.csv")
vcvcov <- cbind(vcvdata,covdata)
vcvcov <- vcvcov[,-1]

# overall data
vcvovrdata <- read.csv("NC2half_vcv_ovr_data.csv")
vcvovrdata$pcentcor <- vcvovrdata$cor*100
vcvcovovr <- cbind(vcvovrdata,covdata)
vcvcovovr <- vcvcovovr[1:11,-1]

# investigate covariates (PTA, wdquiet, worstthresh, age)
xyplot(pcentcor ~ age, 
       groups = HA, 
       data = vcvcov,  
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
model1 = lm(pcentcor ~ age*HA, data=vcvcov)
anova(model1)

model1 = aov(pcentcor ~ HA*cond + Error(snum/cond), data=vcvcov)
summary(model1)