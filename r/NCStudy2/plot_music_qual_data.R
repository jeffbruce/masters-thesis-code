##### plot_music_qual_data.r
##### PLOTS ONLY GROUP FIGURES

##### DEFINITIONS, LIBRARIES, LOAD DATA SETS
library(ggplot2)
setwd("C:/Users/Jeff/Documents/McMaster University/Data & Analysis/NCStudy2 Data - March 28 2013/")
musqualdata <- read.csv("NC2half_music_quality_summary_data.csv",header=T)
stderr <- function(x) sqrt(var(x)/length(x))

###### PREPROCESS GROUP DATA
groupscore <- data.frame(with(musqualdata, tapply(score,list(HA,quality),mean)))
HAnames <- row.names(groupscore)
groupscore$HA <- HAnames
groupscore <- melt(groupscore)
names(groupscore) <- c("HA","quality","score")
groupstderr <- data.frame(with(musqualdata, tapply(score,list(HA,quality),stderr)))
groupstderr <- melt(groupstderr)
groupscore$sem <- groupstderr$value
groupscore

##### PLOT GROUPS
ggplot(groupscore,aes(x=quality,y=score,fill=HA)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=score-sem, ymax=score+sem),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  xlab("Questionnaire") +
  ylab("Composite Score") +
  opts(title="Group Sound Quality Measures") +
  scale_y_continuous(breaks=2:10*.5) +
  theme_bw()