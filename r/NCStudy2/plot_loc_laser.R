library(ggplot2)
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013/")
stderr <- function(x) sqrt(var(x)/length(x))

#LOAD DATA FRAME WITH ALL DATA FROM NC, AND ANOTHER FOR ALL DATA FROM WDRC
locdata <- read.csv("loc_laser_data.csv",header=T)
locdata$freq <- as.factor(locdata$freq)
levels(locdata$freq) <- c("low","high","phone")

##### LOAD LOC DATA INTO APPROPRIATE FORMAT
locdatacond <- read.csv("loc_summary_data_cond.csv",header=T)
locdatacond <- melt(locdatacond)
names(locdatacond) <- c("name","num","HA","Condition","Error")
locdataspk <- read.csv("loc_summary_data_speaker.csv",header=T)
locdataspk <- melt(locdataspk)
names(locdataspk) <- c("name","num","HA","Angle","Error")
levels(locdataspk$Angle) <- c(0,15,30,45,60,75,90)

##### CALCULATE AVG ERROR BY CONDITION
grouperr <- data.frame(with(locdatacond, tapply(Error,list(HA,Condition),mean)))
HAnames <- row.names(grouperr)
grouperr$HA <- HAnames
grouperr <- melt(grouperr)
names(grouperr) <- c("HA","Condition","Error")
groupstderr <- data.frame(with(locdatacond, tapply(Error,list(HA,Condition),stderr)))
groupstderr <- melt(groupstderr)
grouperr$stderr <- groupstderr$value
grouperr

##### PLOT GROUP BY CONDITION
ggplot(grouperr, aes(x=Condition, y=Error, fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  geom_errorbar(aes(ymin=Error-stderr, ymax=Error+stderr),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Stimulus Type") +
  ylab("Error (°)") +
  opts(title="      Localization Error by Condition") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()

##### CALCULATE AVG ERROR BY SPEAKER
grouperr <- data.frame(with(locdataspk, tapply(Error,list(HA,Angle),mean)))
HAnames <- row.names(grouperr)
grouperr$HA <- HAnames
grouperr <- melt(grouperr)
names(grouperr) <- c("HA","Angle","Error")
groupstderr <- data.frame(with(locdataspk, tapply(Error,list(HA,Angle),stderr)))
groupstderr <- melt(groupstderr)
grouperr$stderr <- groupstderr$value
levels(grouperr$Angle) <- c("0","15","30","45","60","75","90")

##### PLOT GROUP BY SPEAKER
ggplot(grouperr, aes(x=Angle, y=Error, fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  geom_errorbar(aes(ymin=Error-stderr, ymax=Error+stderr),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Angle From Centre (°)") +
  ylab("Error (°)") +
  opts(title="      Localization Error from Centre") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()

##### CALCULATE AVG ERROR BY SPEAKER*COND
grouperr <- data.frame(with(locdata, tapply(err_deg,list(HA,freq,stim_deg),mean)))
grouperr <- melt(grouperr)
grouperr$Angle <- rep(c("0","15","30","45","60","75","90"), each=6)
grouperr$variable <- rep(c("low","low","high","high","phone","phone"),7)
grouperr$HA <- rep(c("NC","WDRC"),21)
groupstderr <- data.frame(with(locdata, tapply(err_deg,list(HA,freq,stim_deg),stderr)))
groupstderr <- melt(groupstderr)
grouperr$sem <- groupstderr$value
names(grouperr) <- c("freq","Error","Angle","HA","sem")

##### PLOT GROUP BY SPEAKER*COND
ggplot(grouperr, aes(x=Angle, y=Error, fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  geom_errorbar(aes(ymin=Error-sem, ymax=Error+sem),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  facet_wrap(~freq, nrow=1) +
  xlab("Stimulus Angle (°)") +
  ylab("Error (|Stimulus - Response|°)") +
  opts(title="Localization Error by Stimulus Type and Angle") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()

##### PLOT PROPORTIONS

#PLOT PROPORTION PLOT FACETED BY NC AND WDRC
ld <- ggplot(locdata,aes(x=stim_deg,y=resp_deg))
#ld + stat_sum()  # not quite
#ld + stat_sum(aes(group = 1))  # overall proportion
ld + stat_sum(aes(group = stim_deg)) +  # proportion within category
  scale_size_continuous(range = c(1, 15),name="proportion") + 
  facet_wrap(~ HA*freq) +
  labs(x = "Stimulus Angle (°)", y = "Response Angle (°)") +
  opts(title="Localization Response Distributions by Hearing Aid and Stimulus Type") +
  scale_x_continuous(breaks=c(0,15,30,45,60,75,90)) +
  scale_y_continuous(breaks=c(0,15,30,45,60,75,90))

# NCSTUDY2 ANALYSIS
#####################################################
library(ez)

subjdata <- with(locdata,tapply(err_deg,list(snum,HA,freq,stim_deg),mean))
subjdata <- melt(subjdata)
names(subjdata) <- c("snum","stim","angle","error")
NCStudy2HAorder <- c("NC","NC","NC","NC","NC","NC","NC","NC","NC","NC","NC","WDRC","WDRC","WDRC","WDRC","WDRC","WDRC","WDRC","WDRC","WDRC","WDRC","WDRC")
subjdata$HA <- rep(NCStudy2HAorder,length(levels(subjdata$fstim))*length(levels(subjdata$fangle)))

# read in covariates
covdata <- read.csv("covariates.csv")
covdata <- covdata[,-1]
covdata <- covdata[with(covdata,order(snum)),]
loccov <- cbind(subjdata,covdata)
loccov <- loccov[,-1]
names(loccov)[1:4] <- c("HA","fstim","fangle","error")
loccov$fstim <- factor(loccov$fstim)
loccov$fangle <- factor(loccov$fangle)

# investigate covariates (PTA, wdquiet, worstthresh, age)
xyplot(error ~ wdquiet, 
       groups = HA, 
       data = loccov,  
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
model1 <- aov(error ~ wdquiet+Error(snum), data=loccov)
summary(model1)

# ANOVA
model1 <- aov(error~HA*fstim*fangle+Error(snum/HA*fstim*fangle),data=loccov)
summary(model1)
ezANOVA(subjdata,error,snum,within=list(fstim,fangle),between=HA,type=1)

# ANCOVA
model1 <- aov(error ~ wdquiet*HA*fstim*fangle+Error(snum/fstim*fangle), data=loccov)
summary(model1)


# NCSTUDY1 ANALYSIS
#####################################################
library(ez)

subjdata <- with(locdata,tapply(err_deg,list(snum,freq,stim_deg,HA),mean))
subjdata <- melt(subjdata)
names(subjdata) <- c("snum","stim","angle","HA","error")
subjdata$fangle <- factor(subjdata$angle)

# read in covariates
covdata <- read.csv("NCStudy1_covariates.csv")
loccov <- cbind(subjdata,covdata)

# investigate covariates (NewLRPTA, satis, worstthresh, age)
xyplot(error ~ age, 
       groups = HA, 
       data = loccov,  
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
model1 <- aov(error ~ age+Error(snum), data=loccov)
summary(model1)

# ANOVA
model1 <- aov(error~HA*stim*fangle+Error(snum/HA*stim*fangle),data=subjdata)
summary(model1)
ezANOVA(subjdata,error,snum,within=list(HA,stim,fangle),type=1)