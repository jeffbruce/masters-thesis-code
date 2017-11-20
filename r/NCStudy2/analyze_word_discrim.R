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


# NCSTUDY2 (correlations = age, PTA, highloss, lowloss, midloss, wdquiet)
###################################################################################################################

# read in data
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013")
wddata <- read.csv("wd_summary_data.csv")

# read in covariates
covdata <- read.csv("covariates.csv")
wdcov <- cbind(wddata,covdata)
wdcov <- wdcov[,-1]

# investigate covariates
xyplot(cor ~ highloss, 
       groups = HA, 
       data = wdcov,  
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
model1 = lm(cor ~ highloss, data=wdcov)
anova(model1)


# ANOVA
#################################
ezANOVA(data=wdcov, dv=cor, wid=snum, within=.(HA,cond),type=3,detailed=TRUE)
wdcov$session <- factor(wdcov$session)
ezANOVA(data=wdcov, dv=cor, wid=snum, within=.(session,cond),type=3,detailed=TRUE)



# PLOTTING
###################################################################

stderr <- function(x) sqrt(var(x)/length(x))
#wddata <- wddata[order(wddata$cond,wddata$HA,wddata$snum),]
levels(wddata$cond) <- rev(levels(wddata$cond))

##### PLOT INDIVIDUALS
ggplot(wddata, aes(x=snum, y=cor, fill=cond)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  facet_wrap(~ HA) +
  xlab("Subject Number") +
  ylab("Percent Correct (%)") +
  opts(title="      Individual Word Recognition Scores By Hearing Aid Type") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()


###### PREPROCESS GROUP DATA
groupcor <- data.frame(with(wddata, tapply(cor,list(HA,cond),mean)))
HAnames <- row.names(groupcor)
groupcor$HA <- HAnames
groupcor <- melt(groupcor)
names(groupcor) <- c("HA","cond","cor")
groupstderr <- data.frame(with(wddata, tapply(cor,list(HA,cond),stderr)))
groupstderr <- melt(groupstderr)
groupcor$stdev <- groupstderr$value
groupcor

##### PLOT GROUPS
ggplot(groupcor,aes(x=cond,y=cor,fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=cor-stdev, ymax=cor+stdev),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Condition") +
  ylab("Percent Correct (%)") +
  opts(title="      Group Word Recognition Scores") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()