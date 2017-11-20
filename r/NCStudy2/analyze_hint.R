# INITIALIZE
#################################
options(contrasts = c("contr.sum","contr.poly"))
library(car)
library(ez)
library(afex) 
library(xtable)  
library(lattice)
library(lme4)


# NCSTUDY1 COMPLETE (covariates are likely uninteresting -- within subjects study)
###################################################################################################################

# READ IN DATA - NCStudy1 Data
#################################
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy1 Data - Nov 2 2012")
hintdata <- read.csv("hint_summary_data.csv")

# read in covariates
covdata <- read.csv("NCStudy1_covariates.csv")
hintcov <- cbind(hintdata,covdata)

# investigate covariates (NewLRPTA, satis, worstthresh, age)
xyplot(SNR ~ worstthresh, 
       groups = HA, 
       data = hintcov,  
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
model1 = lm(SNR ~ worstthresh, data=hintcov)
anova(model1)

# ONE WAY ANOVA
#################################
hint.aov <- aov(SNR ~ HA + Error(snum/HA),data=hintdata)
summary(hint.aov)
ezANOVA(hintdata, SNR, snum, within=HA, type=3)

# EFFECTS OF SESSION?
#################################
hint.aov = aov(SNR ~ session + Error(snum/session), data=hintdata)
summary(hint.aov)
print(model.tables(mhn.aov,"means"),digits=3)

# EFFECT OF LIST?
#################################
hint.aov = aov(SNR ~ list + Error(snum/list), data=hintdata)
summary(hint.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# NCSTUDY2 HALFWAY (covariates = age, worstthresh, PTA, wdquiet)
# the groups mainly only differ in wdquiet, and worstthresh but worstthresh seems arbitrary
###################################################################################################################

# TYPE I ANALYSIS USING R STANDARD METHODS
#################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - March 28 2013")
hintdata <- read.csv("NC2half_hint_summary_data.csv")

# read in covariates
covdata <- read.csv("NC2half_covariates.csv")
hintcov <- cbind(hintdata,covdata)

# investigate covariates (PTA, wdquiet, worstthresh, age)
xyplot(SNR ~ worstthresh, 
       groups = HA, 
       data = hintcov,  
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
model1 = lm(SNR ~ worstthresh*HA, data=hintcov)
anova(model1)


# ANOVA
#################################
model1 = lm(SNR ~ HA, data=hintcov)
anova(model1)

# ANCOVA
#################################
hint.aov <- aov(SNR ~ wdquiet + HA, data=hintcov)
summary(hint.aov)

# EFFECT OF LIST?
#################################
hint.aov = aov(SNR ~ list, data=hintcov)
summary(hint.aov)



# NCSTUDY2 (correlations = age, PTA, highloss, lowloss, midloss, wdquiet)
###################################################################################################################

# TYPE I ANALYSIS USING R STANDARD METHODS
#################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013")
hintdata <- read.csv("hint_summary_data.csv")

# read in covariates
covdata <- read.csv("covariates.csv")
hintcov <- cbind(hintdata,covdata)
hintcov <- hintcov[,-1]

# investigate covariates
xyplot(SNR ~ wdquiet, 
       groups = HA, 
       data = hintcov,  
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
model1 = lm(SNR ~ wdquiet, data=hintcov)
anova(model1)


# ANOVA
#################################
ezANOVA(data=hintcov, dv=SNR, wid=snum, within=HA,type=3,detailed=TRUE)
hintcov$session <- factor(hintcov$session)
ezANOVA(data=hintcov, dv=SNR, wid=snum, within=session,type=3,detailed=TRUE)
ezANOVA(data=hintcov, dv=SNR, wid=snum, within=list,type=3,detailed=TRUE)

# EFFECT OF LIST?
#################################
hint.aov = aov(SNR ~ list+Error(snum/list), data=hintcov)
summary(hint.aov)

# EFFECT OF SESSION?
#################################
hint.aov = aov(SNR ~ session+Error(snum/session), data=hintcov)
summary(hint.aov)