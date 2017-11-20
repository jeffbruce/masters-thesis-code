One-Way Within-Subjects Designs

-each block consists of a single subject
-synonomous with repeated-measures designs, but some statisticians reserve
 that term for studies with the same dependent measure taken several times
-could imagine a situation where many measures are taken which differ
 qualitatively, such as response time on a visual task, a BDI score, and a
 WAIS score.  this kind of design should be analyzed with a multivariate
 design, covered in chapters 13 and 14 in the textbook.
-the basic approach here is to treat subjects as an experimental factor
-the subjects factor is a random factor
-unlike in previous designs, the observations are correlated, not independent.
-all of the following analyses assume that we are working with balanced
 data.

Linear model
Yij = mu + alpha(j) + pi(i) + pi*alpha(ij) + e(ij)
TOO MANY PARAMETERS, SO THE MODEL SIMPLIFIES TO:
Yij = mu + alpha(j) + pi(i) + e(ij)
-by dropping the interaction, we are incorporating the interaction in with
 the error term
-in this design, the residuals term IS the interaction, and vice versa

H0: alpha(1) == ... == alpha(j)
restricted model: Yij = mu + pi(i) + e(ij)

F test is computed in the same way:
F = (Er - Ef)(df(r) - df(f))/(Ef/df(f))

df(f) = (n-1)(a-1)
      = degrees of freedom for the deleted group*subjects interaction
df(r) = n(a-1)

when the model is fit to data, the best coefficients are:
mu = Ybar(..)
alpha(j) = Ybar(.j) - Ybar(..)
pi(i) = Ybar(i.) - Ybar(..)
MSerror table on pg. 4

-compare MStreatment to MSinteraction or MSresiduals in this design is
 a reasonable test of the null hypothesis

SPHERICITY
-it is reasonable to expect that the errors a subject makes across 
 conditions will be correlated
-instead of assuming that errors are independent, we assume that the
 errors form a dependency: all covariances between dependent variables are
 equal
-the combination of assumptions made (equal variance for all dependent vars,
 and equal covariance between each pair of dependent variables) is called
 compound symmetry
-the F calculated with the formula above is distributed as an F statistic
 with df = [(a-1),(n-1)(a-1)] if the dependent vars obey compound symmetry
-compound symmetry is sufficient, but not necessary, and the F formula is
 still distributed as an F statistic if just the variance of the difference
 of all pairs of dependent vars are the same
-when the above condition is met, the variance-covariance matrix of the
 dependent variables is spherical, so this assumption is the sphericity
 assumption
-when sphericity is violated (often the case), the F value is instead
 distributed with lower degrees of freedom.  these are adjusted by
 multiplying be epsilon, which is the degree to which sphericity is violated.
-one strategy is to assume epsilon is 1/(a-1), the minimum value, and this
 constitutes a conservative F test
-alternatively, can derive an estimate of epsilon based on the variance-
 covariance matrix of the dependent measures
-the GG correction and HF correction are both ways of estimating epsilon
 based on the properties of the variance-covariance matrix of our
 dependent measures, and GG is more conservative than HF
-the Mauchly test for sphericity has been criticized for being low power,
 so might want to use a more liberal type I error rate of alpha=0.1 to
 evaluate sphericity

CODE  #shown for gap detection
gap.mlm <- lm(cbind(NC,WDRC)~1, data=gapdata)
(HA <- factor(x = c("nc","wdrc"), ordered=FALSE))
library(car)
gap.aov <- Anova(gap.mlm, idata=data.frame(HA), idesign=~HA, type="III")
summary(gap.aov, multivariate = FALSE)