# INITIALIZE
#################################
options(contrasts = c("contr.sum","contr.poly"))
library(car)
library(ez)  
library(afex)  
library(xtable) 
library(lattice)
#################################


# NCSTUDY1 COMPLETE (covariates are likely uninteresting -- within subjects study)
###################################################################################################################

# READ IN DATA
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy1 Data - Nov 2 2012")
mhndata <- read.csv("mhn_summary_data.csv")

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("NCStudy1_covariates.csv")
mhncov <- cbind(mhndata,covdata)

# investigate covariates (NewLRPTA, satis, worstthresh, age)
xyplot(thresh ~ worstthresh, 
       groups = HA, 
       data = mhncov,  
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
model1 <- lm(thresh ~ worstthresh, data=mhncov)
anova(model1)

model1 <- aov(thresh ~ HA*harm + Error(snum/HA*harm), data=mhncov)
summary(model1)

model1 <- ezANOVA(mhncov, thresh, snum, within=list(HA,harm))
print(model1)


# EFFECTS ACROSS SESSIONS
mhn.aov = aov(thresh ~ session + Error(snum/session), data=mhncov)
summary(mhn.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# NCSTUDY2 HALFWAY (covariates = age, worstthresh, PTA, wdquiet)
# the groups mainly only differ in wdquiet, and worstthresh but worstthresh seems arbitrary
###################################################################################################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - March 28 2013")
mhndata <- read.csv("NC2half_mhn_summary_data.csv")

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("NC2half_covariates.csv")
mhncov <- cbind(mhndata,covdata)
mhncov <- mhncov[,-6:-7]
mhncov$wdquiet_centre <- mhncov$wdquiet - mean(mhncov$wdquiet)  # 0 centred!

# investigate covariates (PTA, wdquiet, worstthresh, age)
xyplot(thresh ~ worstthresh, 
       groups = HA, 
       data = mhncov,  
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
model1 <- lm(thresh ~ worstthresh, data=mhncov)
anova(model1)

# analysis without a covariate
model1 <- aov(thresh ~ HA*tone + Error(sname/tone), data=mhncov)
summary(model1)

# wdquiet is significant, so it is worth running it with a covariate
model1 <- aov(thresh ~ wdquiet_centre*HA*tone + Error(sname/tone), data=mhncov)
summary(model1)

# WITHOUT covariate of wdquiet
t2table <- ez.glm("sname", "thresh", mhncov, between = "HA", within = "tone", covariate = "wdquiet_centre",print.formula = TRUE,type=3)
#print(xtable(t2table),type="latex")
t2table


# NCSTUDY2 (correlations = age, PTA, highloss, lowloss, midloss, wdquiet)
###################################################################################################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013")
mhndata <- read.csv("mhn_summary_data.csv")

covdata <- read.csv("covariates.csv")
mhncov <- cbind(mhndata,covdata)
mhncov <- mhncov[,-8:-9]
#mhncov$wdquiet_centre <- mhncov$wdquiet - mean(mhncov$wdquiet)  # 0 centred!
mhncov$thresh100 <- mhncov$thresh*100 - 100

# investigate covariates
xyplot(thresh ~ lowloss, 
       groups = HA, 
       data = mhncov,  
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
model1 <- lm(thresh ~ wdquiet, data=mhncov)
anova(model1)

model1 = aov(thresh100 ~ HA*harm+Error(snum/HA*harm), data=mhncov)
summary(model1)
#lapply(summary(model1), xtable)
aovtab <- do.call(rbind.fill, lapply(1:length(summary(model1)), function(x) unclass(summary(model1)[[x]])[[1]]))
SOV <- unlist(lapply(1:length(summary(model1)), function(x) rownames(unclass(summary(model1)[[x]])[[1]])))
print(xtable(cbind(SOV, aovtab), include.rownames=F))

# afex and EZ don't create objects of the right type, which makes it difficult to use xtable
# ezANOVA and afex don't produce the best tables, in that SS and MS are not created, and
#   residuals are not shown
# generalized eta squared changes a lot between type=1 and type=3
ezANOVA(data=mhncov, dv=thresh100, wid=snum, within=.(HA,harm), type=3,detailed=TRUE)


# EFFECTS ACROSS SESSIONS
mhncov$session <- factor(mhncov$session)
ezANOVA(data=mhncov, dv=thresh100, wid=snum, within=.(session,harm), type=3,detailed=TRUE)