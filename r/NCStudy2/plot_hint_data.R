##### plot_hint_data.r
##### PLOTS BOTH INDIVIDUAL AND GROUP HINT DATA

##### DEFINITIONS, LIBRARIES, LOAD DATA SETS
library(ggplot2)
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013/")
hintdata <- read.csv("hint_summary_data.csv",header=T)
stderr <- function(x) sqrt(var(x)/length(x))

##### PLOT INDIVIDUALS
ggplot(hintdata, aes(x=snum, y=SNR, fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  geom_errorbar(aes(ymin=SNR-stdev, ymax=SNR+stdev),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Subject Number") +
  ylab("Speech Reception Threshold (SNR at 50% Correct)") +
  opts(title="Individual HINT Speech Reception Thresholds") +
  scale_y_continuous(breaks=-10:10) +
  theme_bw()

###### PREPROCESS GROUP DATA
groupSNR <- with(hintdata, tapply(SNR,HA,mean))
groupstderr <- with(hintdata, tapply(SNR,HA,stderr))
grouphint <- data.frame(groupSNR,groupstderr)

##### PLOT GROUPS
ggplot(grouphint, aes(x=rownames(grouphint), y=groupSNR)) + 
  geom_bar(width=.25, fill="lightblue", position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=groupSNR-groupstderr, ymax=groupSNR+groupstderr),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Hearing Aid") +
  ylab("Speech Reception Threshold (SNR at 50% Correct)") +
  opts(title="Group HINT Speech Reception Thresholds") +
  ylim(-1,1) +
  theme_bw()