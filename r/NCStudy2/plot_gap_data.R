##### plot_gap_data.r
##### PLOTS BOTH INDIVIDUAL AND GROUP FIGURES

##### DEFINITIONS, LIBRARIES, LOAD DATA SETS
library(ggplot2)
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013/")
gapdata <- read.csv("gap_summary_data.csv",header=T)
stderr <- function(x) sqrt(var(x)/length(x))

##### PREPROCESS INDIVIDUAL DATA
gapdata$avethresh <- rowMeans(gapdata[,4:6])

##### PLOT INDIVIDUALS
ggplot(gapdata, aes(x=snum, y=avethresh, fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=avethresh-avstd, ymax=avethresh+avstd),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Subject Number") +
  ylab("Gap Threshold (msec)") +
  opts(title="      Individual Gap Detection Thresholds") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()

###### PREPROCESS GROUP DATA
groupthresh <- with(gapdata, tapply(avethresh,HA,mean))
groupstderr <- with(gapdata, tapply(avethresh,HA,stderr))
groupgap <- data.frame(groupthresh,groupstderr)

##### PLOT GROUPS
ggplot(groupgap, aes(x=rownames(groupgap), y=groupthresh)) + 
  geom_bar(width=.5, fill="lightblue", position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=groupthresh-groupstderr, ymax=groupthresh+groupstderr),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Hearing Aid") +
  ylab("Gap Threshold (msec)") +
  opts(title="      Group Gap Detection Thresholds") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()