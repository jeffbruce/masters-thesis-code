# INITIALIZE
#################################
options(contrasts = c("contr.sum","contr.poly"))
library(RODBC)
library(car)


# READ IN DATA
#################################
# only works for .xls, not .xlsx!
setwd("C:\\Users\\Jeff\\Documents\\MATLAB\\Neuro-Compensator\\music quality")
ch <- odbcConnectExcel("music_quality_summary_data.xls")
mqdata <- sqlFetch(ch, gsub("'|\\$", "", sqlTables(ch)$TABLE_NAME[1])) 
close(ch)
mqdata


# CAR METHOD
#################################
gap.mat <- as.matrix(gapdata[,2:5])
gap.mlm <- lm(gap.mat~1)
HA <- factor(c("nc","nc","wdrc","wdrc"), ordered=FALSE)
harm <- factor(c("350","1050","350","1050"), ordered=FALSE)
timbre.idata <- data.frame(HA,harm)
timbre1.aov <- Anova(timbre.mlm, idata=timbre.idata, idesign=~HA*harm, type="III")
summary(timbre1.aov, multivariate = FALSE)


# PERSONALITY PROJECT METHOD
#################################
mq.aov = aov(mus_comp ~ HA + Error(Name/(HA)), data=mqdata)
summary(mq.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# EFFECTS ACROSS SESSIONS
#################################
gap.aov = aov(thresh ~ session*block + Error(sname/(session*block)), data=gapdata)
summary(gap.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# DROP1 METHOD
# ***MUST NOT PROPERLY CODE FOR THE WITHIN-SUBJECT ERROR TERMS!***
#################################
timbre.aov <- aov(thresh~HA+harm+HA:harm,data=timbredata)
drop1(timbre.aov,.~.,test="F")