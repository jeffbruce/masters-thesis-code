# INITIALIZE
#################################
options(contrasts = c("contr.sum","contr.poly"))
library(RODBC)
library(car)


# READ IN DATA
#################################
# only works for .xls, not .xlsx!
setwd("C:\\Users\\Jeff\\Documents\\MATLAB\\Neuro-Compensator\\mistuned harmonic noise")
ch <- odbcConnectExcel("mhn_summary_data.xls")
mhndata <- sqlFetch(ch, gsub("'|\\$", "", sqlTables(ch)$TABLE_NAME[1])) 
close(ch)
mhndata


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
mhn.aov = aov(thresh ~(HA*harm) + Error(sname/(HA*harm)), data=mhndata)
summary(mhn.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# EFFECTS ACROSS SESSIONS
#################################
mhn.aov = aov(thresh ~ session*harm + Error(sname/(session*harm)), data=mhndata)
summary(mhn.aov)
print(model.tables(mhn.aov,"means"),digits=3)


# DROP1 METHOD
# ***MUST NOT PROPERLY CODE FOR THE WITHIN-SUBJECT ERROR TERMS!***
#################################
timbre.aov <- aov(thresh~HA+harm+HA:harm,data=timbredata)
drop1(timbre.aov,.~.,test="F")