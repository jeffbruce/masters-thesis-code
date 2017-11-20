# INITIALIZE
#################################
options(contrasts = c("contr.sum","contr.poly"))
library(RODBC)
library(car)


# READ IN DATA
#################################
# only works for .xls, not .xlsx!
setwd("C:\\Users\\Jeff\\Documents\\MATLAB\\Neuro-Compensator\\loc laser")
ch <- odbcConnectExcel("loc_summary_data_speaker_R.xls")
locdata <- sqlFetch(ch, gsub("'|\\$", "", sqlTables(ch)$TABLE_NAME[1])) 
close(ch)
locdata


# CAR METHOD
#################################
mhn.mat <- as.matrix(mhndata[,2:5])
mhn.mlm <- lm(mhn.mat~1)
HA <- factor(c("nc","nc","wdrc","wdrc"), ordered=FALSE)
harm <- factor(c("350","1050","350","1050"), ordered=FALSE)
timbre.idata <- data.frame(HA,harm)
timbre1.aov <- Anova(timbre.mlm, idata=timbre.idata, idesign=~HA*harm, type="III")
summary(timbre1.aov, multivariate = FALSE)


# PERSONALITY PROJECT METHOD
#################################
loc.aov = aov(spk1 ~(HA*spk) + Error(name/(HA*spk)), data=locdata)
summary(loc.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# EFFECTS ACROSS SESSIONS
#################################
loc.aov = aov(error ~ session + Error(num/session), data=locdata)
summary(loc.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# DROP1 METHOD
# ***MUST NOT PROPERLY CODE FOR THE WITHIN-SUBJECT ERROR TERMS!***
#################################
timbre.aov <- aov(thresh~HA+harm+HA:harm,data=timbredata)
drop1(timbre.aov,.~.,test="F")