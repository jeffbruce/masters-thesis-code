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
timbredata <- read.csv("timbre_summary_data.csv")

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("NCStudy1_covariates.csv")
timbrecov <- cbind(timbredata,covdata)

# investigate covariates (NewLRPTA, satis, worstthresh, age)
xyplot(thresh ~ NewLRPTA, 
       groups = HA, 
       data = timbrecov,  
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
model1 <- lm(thresh ~ NewLRPTA, data=timbrecov)
anova(model1)

model1 <- aov(thresh ~ HA+harm+HA:harm + Error(snum/HA*harm), data=timbrecov)
summary(model1)

model1 <- ezANOVA(timbrecov, thresh, snum, within=list(HA,harm))
print(model1)

# EFFECTS ACROSS SESSIONS
timbre.aov = aov(thresh ~ session + Error(snum/session), data=timbrecov)
summary(timbre.aov)
print(model.tables(mhn.aov,"means"),digits=3)




# NCSTUDY2 HALFWAY (covariates = age, worstthresh, PTA, wdquiet)
# the groups mainly only differ in wdquiet, and worstthresh but worstthresh seems arbitrary
###################################################################################################################


# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - March 28 2013")
timbredata <- read.csv("NC2half_timbre_summary_data.csv")

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("NC2half_covariates.csv")
timbrecov <- cbind(timbredata,covdata)
timbrecov <- timbrecov[,-7:-8]
timbrecov$wdquiet_centre <- timbrecov$wdquiet - mean(timbrecov$wdquiet)  # 0 centred!

# investigate covariates (PTA, wdquiet, worstthresh, age)
xyplot(thresh ~ wdquiet, 
       groups = HA, 
       data = timbrecov,  
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
model1 <- lm(thresh ~ wdquiet, data=timbrecov)
anova(model1)
# none of the covariates are close to significance, so not worth running an ANCOVA

# WITHOUT covariate of wdquiet
t2table <- ez.glm("snum", "thresh", timbrecov, between = "HA", within = "harm", covariate = "wdquiet",print.formula = TRUE,type=3)
#print(xtable(t2table),type="latex")
t2table

aov.car(thresh ~ HA + wdquiet_centre + Error(snum/harm), data = timbrecov, return="Anova")

# I DONT UNDERSTAND WHY THERE IS NO wd:HA interaction!




# NCSTUDY2 (correlations = age, PTA, highloss, lowloss, midloss, wdquiet)
###################################################################################################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013")
timbredata <- read.csv("timbre_summary_data.csv")

# read in covariates, amalgamate into gapcov data frame
covdata <- read.csv("covariates.csv")
timbrecov <- cbind(timbredata,covdata)
timbrecov <- timbrecov[,-8:-9]

# investigate covariates
xyplot(thresh ~ midloss, 
       groups = HA, 
       data = timbrecov,  
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
model1 <- lm(thresh ~ midloss, data=timbrecov)
anova(model1)

#one problem with the traditional aov method is it assumes sphericity and
#doesn't allow for Mauchley's test and Tukey tests, and I'm even getting
#weird output with it
model1 = aov(thresh ~ harm*HA+Error(snum/harm*HA), data=timbrecov)
summary(model1)
#lapply(summary(model1), xtable)
aovtab <- do.call(rbind.fill, lapply(1:length(summary(model1)), function(x) unclass(summary(model1)[[x]])[[1]]))
SOV <- unlist(lapply(1:length(summary(model1)), function(x) rownames(unclass(summary(model1)[[x]])[[1]])))
print(xtable(cbind(SOV, aovtab), include.rownames=F))

# doesn't work
lmer(thresh ~ 1 + HA*harm + (HA*harm|snum), data=timbrecov)

# afex and EZ don't create objects of the right type, which makes it difficult to use xtable
# ezANOVA and afex don't produce the best tables, in that SS and MS are not created, and
#   residuals are not shown
# generalized eta squared changes a lot between type=1 and type=3
ezANOVA(timbrecov, thresh, snum, within=list(HA,harm), type=3)
timbrecov$session <- factor(timbrecov$session)
ezANOVA(timbrecov, thresh, snum, within=list(session,harm), type=3)


# afex doesn't allow type I, annoyingly
#ac <- aov.car(thresh ~ Error(snum/HA*harm), data=mhndata, type=2, return="Anova")

# EFFECTS ACROSS SESSIONS
timbre.aov <- aov(thresh ~ session*harm + Error(snum/session*harm), data=timbrecov)
summary(timbre.aov)
