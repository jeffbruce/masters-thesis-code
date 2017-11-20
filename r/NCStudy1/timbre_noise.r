# INITIALIZE
#################################
options(contrasts = c("contr.sum","contr.poly"))
library(RODBC)
library(car)


# READ IN DATA
#################################
# only works for .xls, not .xlsx!
setwd("C:\\Users\\Jeff\\Documents\\MATLAB\\Neuro-Compensator\\timbre perception noise")
ch <- odbcConnectExcel("timbre_summary_data_sesh_long.xls")
timbredata <- sqlFetch(ch, gsub("'|\\$", "", sqlTables(ch)$TABLE_NAME[1])) 
close(ch)
timbredata


# PLOT BAR GRAPH WITH ggplot2
################################# example
dfc <- read.table("dfc.txt", header = TRUE, sep = ",")
dfc2 <- dfc
dfc2$dose <- factor(dfc2$dose)
ggplot(dfc2, aes(x=dose, y=len, fill=supp)) + 
    geom_bar(position=position_dodge()) +
    geom_errorbar(aes(ymin=len-se, ymax=len+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))

timbretest <- read.table("timbretest.txt", header=TRUE, sep="\t")
ggplot(timbretest, aes(x=harm, y=mean, fill=HA)) +
    geom_bar(position=position_dodge()) +
    geom_errorbar(aes(ymin=mean-se, ymax=mean+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))

# CAR METHOD
#################################
timbre.mat <- as.matrix(timbredata[,2:5])
timbre.mlm <- lm(timbre.mat~1)
HA <- factor(c("nc","nc","wdrc","wdrc"), ordered=FALSE)
harm <- factor(c("350","1050","350","1050"), ordered=FALSE)
timbre.idata <- data.frame(HA,harm)
timbre1.aov <- Anova(timbre.mlm, idata=timbre.idata, idesign=~HA*harm, type="III")
summary(timbre1.aov, multivariate = FALSE)


# PERSONALITY PROJECT METHOD
#################################
timbre.aov = aov(thresh ~(HA*harm) + Error(sname/(HA*harm)), data=timbredata)
summary(timbre.aov)
print(model.tables(timbre.aov,"means"),digits=3)

#timbre.aov = aov(intensity ~ session, data=timbredata)


# EFFECTS ACROSS SESSIONS
#################################
timbre.aov = aov(thresh ~ session*harmonic + Error(sname/(session*harmonic)), data=timbredata)
summary(timbre.aov)
print(model.tables(timbre.aov,"means"),digits=3)



# DROP1 METHOD
# ***MUST NOT PROPERLY CODE FOR THE WITHIN-SUBJECT ERROR TERMS!***
#################################
timbre.aov <- aov(thresh~HA+harm+HA:harm,data=timbredata)
drop1(timbre.aov,.~.,test="F")