Factorial Within-Subjects Designs

Assumptions made:
- balanced dataset
- experimental factors are fixed, subject variable is random (can generalize)

Full model:
Y(ijk) = mu + alph(j) + beta(k) + pi(i) + alph.beta(jk) + alph.pi(ji) + beta.pi(ki)
       + alph.beta.pi(jki) + e(ijk)
- anything with pi is a random effect, anything else is a fixed effect
- magnitude of each effect obtained by comparing this model to a restricted
  model not containing the effect of interest
- only differs from between-subjects designs in the choice of the error term for
  each F test
- there is no MSwithincell term, because every cell is a single observation, so we
  can't estimate this like we did with between-subjects designs
- like one-way within-subjects, we compare the main effect to treatment*subjects 
  interaction, which represents the combined error and treatment*subjects 
  interaction
- we compare the A*B effect to A*B*subjects interaction

Commands:
1) create matrix of dependent variable data (use as.matrix)
2) create multivariate linear model (lm(dependent ~ 1, data=whatever))
3) create idata object to submit to Anova (dataframe of correct dimensions)
   angle  noise
1  0	    abs
2  4      abs 
3  8	    abs
4  0      pres
5  4      pres
6  8      pres
4) create aov object, summary 
   summary(Anova(mlm, idata= , idesign= ~angle*noise, type="III"),multivariate=F)
- notice the df for the error terms to evaluate the F test may be different for
  each factor, unlike between-subjects designs

Association Strength:
partial omega (A) w^2 = sigma(alph)^2/(sigma(alph)^2+sigma(e)^2)
partial omega (A) w^2 = (a-1)(FA-1)/((a-1)(FA-1) + nab)
- association strength is calculated differently in the text, in that it includes
  variation due to subjects, therefore this value will be greater than the one
  calculated in the text

Simple Main Effects:
- essentially identical to conducting separate, one-way within subjects ANOVAs

Linear Comparisons:
1) create contrast weights
2) create composite scores (for F test or t test)
3) analyze with F test or t test