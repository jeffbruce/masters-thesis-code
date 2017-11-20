##### plot_timbre_data.r
##### PLOTS BOTH INDIVIDUAL AND GROUP FIGURES

##### DEFINITIONS, LIBRARIES, LOAD DATA SETS
library(ggplot2)
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - May 11 2013/")
timbredata <- read.csv("timbre_summary_data.csv",header=T)
names(timbredata)[5] <- "harm"
stderr <- function(x) sqrt(var(x)/length(x))

##### PREPROCESS THE DATAFRAME
levels(timbredata$harm) <- c("Fundamental","2nd Harmonic")

##### PLOT INDIVIDUALS
ggplot(timbredata, aes(x=snum, y=thresh, fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  geom_errorbar(aes(ymin=thresh-stdev, ymax=thresh+stdev),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  facet_wrap(~ harm) +
  xlab("Subject Number") +
  ylab("Intensity Threshold (%)") +
  opts(title="      Individual Harmonic Intensity Thresholds") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()

###### PREPROCESS GROUP DATA
groupthresh <- data.frame(with(timbredata, tapply(thresh,list(HA,harm),mean)))
HAnames <- row.names(groupthresh)
groupthresh$HA <- HAnames
groupthresh <- melt(groupthresh)
names(groupthresh) <- c("HA","harm","thresh")
levels(groupthresh$harm) <- c("Fundamental","2nd Harmonic")
groupstderr <- data.frame(with(timbredata, tapply(thresh,list(HA,harm),stderr)))
groupstderr <- melt(groupstderr)
groupthresh$stdev <- groupstderr$value
groupthresh

##### PLOT GROUPS
ggplot(groupthresh,aes(x=harm,y=thresh,fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=thresh-stdev, ymax=thresh+stdev),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Harmonic") +
  ylab("Intensity Threshold (%)") +
  opts(title="      Group Harmonic Intensity Thresholds") +
  scale_y_continuous(breaks=0:20*5) +
  theme_bw()