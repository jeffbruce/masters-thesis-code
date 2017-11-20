Split Plot Designs

- mixture of within-subjects and between-subjects
- for expected mean squares, consult table 12.17 (pg 596) in textbook

Commands:
- same as factorial within-subjects ANOVA, but including a group term in the lm

Interpreting the ANOVA Table:
- the between-subjects effect in the split plot is the same as a one-way
  between-subjects ANOVA on the scores averaged over the within-subjects factor
  (the sums of squares and mean squares will look different, but their ratios
   are the same)
- having unequal n on the between-subjects factor will not cause problems with the
  analysis, but the within-subjects factor is a different story
- the within-subjects effect is evaluated with an error term corresponding to
  B*S/A, the interaction between B and subjects, nested in between-subjects factor
  A; this error term is equivalent to the weighted average of MS(B*S) at each
  level of the between-subjects variable A (average of several within-subjects
  ANOVA tables)

Simple Main Effects:
- simple main effects of the between-subjects variable A is just several
  one-way between-subjects ANOVAs, this time with different error terms
- simple main effects of the within-subjects variable B is just several
  one-way within-subjects ANOVAs, again with different error terms
  (it's possible to use a pooled error term from our overall analysis, and this
   is what SPSS does which gives greater power, but assumes that the error
   is the same at each level of the between-subjects variable)

Linear Comparisons (Between-Subjects Variable):
- compute average score on the within-subjects variables, then perform contrast
  as one would with a one-way between subjects design

Linear Comparisons (Within-Subjects Variable):
- compute composite scores, then evaluate using a t test
- alternatively, use an F test to control for the interaction by running a
  between-subjects ANOVA on the composite scores, and checking the intercept
- note that the F test uses an error term that does NOT include variation
  associated with the group:contrast interaction, but the t test does,
  and this is reflected in the degrees of freedom of the F and t tests
