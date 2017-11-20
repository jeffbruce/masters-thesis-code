##### plot_mhn_data.r
##### PLOTS BOTH INDIVIDUAL AND GROUP FIGURES

##### DEFINITIONS, LIBRARIES, LOAD DATA SETS
library(ggplot2)
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013/")
mhndata <- read.csv("mhn_summary_data.csv",header=T)
stderr <- function(x) sqrt(var(x)/length(x))

##### PREPROCESS INDIVIDUAL DATA
mhndata$threshpcent <- (mhndata$thresh-1)*100
mhndata$stdpcent <- mhndata$std*100
mhndata$tone <- mhndata$harm
levels(mhndata$tone) <- c("200 Hz","600 Hz")

##### PLOT INDIVIDUALS
ggplot(mhndata, aes(x=snum, y=threshpcent, fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  geom_errorbar(aes(ymin=threshpcent-stdpcent, ymax=threshpcent+stdpcent),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  facet_wrap(~ tone) +
  xlab("Subject Number") +
  ylab("Mistuned Threshold (%)") +
  opts(title="      Individual Mistuned Harmonic Thresholds") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()

###### PREPROCESS GROUP DATA
groupthresh <- data.frame(with(mhndata, tapply(threshpcent,list(HA,tone),mean)))
HAnames <- row.names(groupthresh)
groupthresh$HA <- HAnames
groupthresh <- melt(groupthresh)
names(groupthresh) <- c("HA","tone","thresh")
levels(groupthresh$tone) <- c("200 Hz","600 Hz")
groupstderr <- data.frame(with(mhndata, tapply(threshpcent,list(HA,tone),stderr)))
groupstderr <- melt(groupstderr)
groupthresh$stdev <- groupstderr$value
groupthresh

##### PLOT GROUPS
ggplot(groupthresh,aes(x=tone,y=thresh,fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=thresh-stdev, ymax=thresh+stdev),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Complex Tone") +
  ylab("Mistuned Threshold (%)") +
  opts(title="      Group Mistuned Harmonic Thresholds") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()