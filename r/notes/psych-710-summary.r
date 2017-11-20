# USEFUL R PACKAGES, COMMANDS, AND STATISTICAL THEORY

# INTIALIZING R
setwd("C:/Users/Jeff/Desktop")
options(contrasts=c("contr.sum","contr.poly"))

# LOADING PACKAGES
install.packages("<package_name>")
library(pwr)  # enables some power analyses
library(car)  # Anova (specify Type III, within sub analyses)
library(ggplot2)  # enables beautiful graphics
library(lattice)  # enables xyplot
library(effects)
library(ez)  
library(afex)  
library(xtable)
library(lme4)

# STATISTICAL THEORY
# anova theory
-idea is to compare sets of nested models
-running a 2 factor anova is like running 3 separate families of
 tests, yet the convention is not to correct for this rise in the 
 experiment-wise Type I error rate
-anova is fairly robust to deviations from normality as long as
 the groups deviate in the same manner and degree
-anova is also fairly robust to deviations of variance by a factor
 of approximately 3
-when sample sizes are different, or when both normality and homog
 of variance are not perfect, then the F test may be error prone
F = ((Er - Ef)/(DFr - DFf))/(Ef/DFf) = MSb/MSw
SSa = Er - Ef = sum_j:a(sum_i:n(alpha_j^2))
SSresid = Ef = sum_j:a(sum_k:b(sum_i:n((Yijk - Ybarjk)^2)))
f = sqrt(sigma_a/sigma_e) or sqrt(partial_w^2/(1-partial_w^2))
# sums of squares (SoS)
-Type I is sequential SoS, for weighted mean comparisons, and is
 how R naturally does the analysis
-Type II evaluates a strange hypothesis and gives increased power
 when interaction is near zero; some camps condone the use of
 Type II when interaction is minimal, others say it isnt worth it
-Type III looks at unweighted means and can be run with:
 drop1(aovModel, .~., test="F")  # type III SoS
# ancova
-blocking is the qualitative category of ancova
-when setting up an ancova model, always put the covariate first (y ~ X + A)
-ancova and blocking partitions the error variance into that associated
 with subjects, and that associate with the baseline measure
-there are some advantages to using a covariate centred around 0
-can use the "effects" package to calculate adjusted means (use avg. level on covariate
 as X value)
effect(term = "group", lm1)
-adjusted means are needed to compute contrasts, and the calculations are tedious so Pat
 has a function which computes them (pg 12 of chapter 9)
-ANCOVA is more sensitive than a difference of pre and post scores, since in the
 difference case, the slope of the covariate is assumed to be 1
-when running a within-subjects ancova, including a zero-centred covariate will NOT 
 change the main effect of the within-subjects factor. So therefore, it doesn`t really 
 make sense to include a covariate in a within-subjects design. There is one purpose 
 for using a covariate though in a within-subjects only design; if one wants to see 
 how the covariate INTERACTS with the within-subjects factor.
# random effects models
-the alphas in a random-effects model are a random variable with mu=0, var=sig_alph^2
-therefore, the var of Yij = sig_e^2 + sig_alph^2
Ex[Ef/DFf] = Ex[MSw] = sig_e^2  # just like in a fixed-effects model
Ex[MSbg] = n*sig_alph^2 + sig_e^2  # when NH is false
-for strength of association, use intraclass correlation, which is the same
 formula as omega squared
# two way factorial with 1 or 2 random factors
-one finnicky detail is that the interaction effects across the levels of the fixed
 factor sum to zero
-the method used to analyze the data is the same, but the expected mean squares differ,
 so a different error term need be used
-the key to analyzing these designs is to look at the expected mean squares table
-when just B is random, compare A to interaction term
 when both A and B are random, compare both MS to interaction MS
# nested factors
-a factor is nested if each level of the factor occurs in only one level of the other
 factor
-the term for the nested factor is a bit different: Bk/j = ujk - uj.
-just like the random effects models, the expected mean squares change, and so
 you need to compare mean squares for each effect to a different residuals term
-always compare the nested factor to the residuals, and the unnested factor to the
 nested factor
-one additional assumption has to be made for nested designs, namely, homogeneity of
 variance of the Bk/j terms at each level of factor A
# single within-subjects designs
-can be conceptualized as a sort of blocking, where each subject is a block
-cant estimate within-cell error with this design, because only 1 obs per treat*subject
-observations in each condition are correlated, and thus sphericity must be examined;
 must assume that the covariance between dependent variables is equal for all pairs
-if one were to include the interaction term (treat*subject) in the model, there would be
 too many parameters; so, the interaction term is rolled into the error term (they are
 the same thing in this design)
-compound symmetry is sufficient but not necessary, in fact all one needs is for the
 variance of all differences between dependent variables to be equal; another way to
 say this is that the variance-covariance matrix of the dependent variables need be
 spherical
# factorial within-subjects designs
-just like in one-way within-subjects, the MStreat term should be compared to
 MStreat*subject
technique for analyzing within-sub designs:
1) create matrix of dependent var data
2) create mlm (using lm) with only dependent var data on left side of equation
3) create idataframe for the factors
4) create aov with car package`s Anova, specifying the mlm, idata, idesign, and SoS type
5) summary(aov obj, multivariate=F)
-there is more information on performing linear contrasts, determining whether
 these contrasts interact with the treatment factors
# mixed models
ez1 = ezANOVA(data=gapdata, dv=.(avthresh), wid=.(sname), within=.(HA))  # can't specify covariate
print(ez1)
gapcov.aov <- aov.car(avthresh ~ HA, data=gapcov, covariate="age", observed="age", return="Anova")
nice.anova(gap.aov)
print(xtable(nice.anova(gap.aov)),type="latex")  # can't do type I SoS with afex

# EVALUATING ANOVA ASSUMPTIONS
shapiro.test(residuals(model))  # test for deviations in normality
qqplot(residuals(model))  # visualize normality of data set
bartlett.test(model)  # test for deviations in variance
boxplot()
oneway.test(model, data=mydata)  # use when only variances between groups may be compromised
kruskal.test(model, mydata)  # non-parametric, doesn't make any assumptions

# POWER ANALYSES
pwr.f2.test(df1, df2, effectsize^2, siglevel)  # calc power
pwr.f2.test(df1, effectsize^2, siglevel, power)  # calc req subjs
power.anova.test()  # not sure if any different from pwr.f2.test

# CREATING/EVALUATING MODELS, USEFUL COMMANDS
aov(model, data=mydata)
lm(model, data=mydata)
anova(model, data=mydata)
summary(lm1, or aov1)
drop1(aovModel, .~., test="F")  # type III SoS
dummy.coef(lm1)  # lists values of effects
confint(model, level = 0.99)
contr.poly(n=4)
cbind(vectors)  # creates a matrix

# t and F VALUES
# q I think finds a critical value, and p finds the probably of obtaining a value
# greater than a certain value
qf
qt
pf
pt
qtukey  # used to find a critical F value

# PAIRWISE COMPARISONS AND LINEAR CONTRASTS
# theory
-it is best to use MSw from whole dataset whenever possible,
 when investigating a simple main effect, contrast, etc.
# lin contrast: method 1 - calculation
calculate psi, SScontrast, MSw, F
compute the probability of obtaining such an F or greater
# lin contrast: method 2 - built in functionality
myC <- cbind(c1, c2)
contrasts(mydata$group) <- myC
mydata.aov <- aov(score ~ group*task, data=mydata)
summary(mydata.aov, split=list(group=list(1)))
# lin contrast: method 3 - linear comparison package
source(url("http://psycserv.mcmaster.ca/bennett/psy710/Rscripts/linear_contrast_v2.R"))
myweights <- c(1,1,-2)  # this can be a list as well
mycontrast <- linear.comparison(y, g, myweights, var.equal=FALSE)
my.contrast[[1]]$F
my.contrast[[1]]$p.2tailed
# Tukey test
TukeyHSD(mydata.aov, which = "group")  # adjusts family-wise alpha
# Scheffe (post-hoc comparisons)
Fscheffe <- (a-1)*qf(1-alpha.fw,df1,df2)  # anova and Scheffe are mutually consistent
# Bonferroni correction / Dunn's procedure
alpha_pc = alpha_fw/c ; c = number of comparisons