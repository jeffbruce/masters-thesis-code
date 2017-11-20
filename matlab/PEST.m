%PEST procedure

% Notes:
% Purpose is to obtain a threshold estimate (Lt) as efficiently and 
% conveniently as possible.
% The next level selected is the one that will give us the most information 
% about the true threshold level (Lt).
% Run is terminated when Lt is at the precision required by the
% experimenter.
% The calculated value of Lt is the last level of testing.

% A. When to Change Levels in PEST
% For each new testing level, experimenter keeps running count of number of
% correct responses N(C) and the total number of trials T.  After each 
% trial, the test defines permissible upper and lower bounds for N(C).  
% If N(C) falls within the bounds, a trial at the same level is delivered, 
% if N(C) falls above, the decision is that the current level is too high, 
% if N(C) falls below, the decision is the current level is too low.
% If we were testing at Lt, the expected number of correct trials E[N(C)] =
% Pt*T.  Sequential test bounds are given by Nb(C)=E[N(C)]+/-W, where Nb(C)
% is the bounding number of events after T trials, and W is a constant,
% called the deviation limit.
% The power of the test and the rapidity of convergence depend in opposite
% ways on W.  
% Small values of W = quick but not very powerful decisions
% Large values of W = longer but much more powerful decisions
% The rapidity but not the power is affected by Pt.  Values of Pt far from
% 0.5 yield decisions slowly if the true event probability associated with
% the current testing level is near Pt.
% For PEST, W=1 has been found to be useful.  With Pt=0.75, a decision
% generally takes 2-25 trials.
% To find a signal yielding d' less than unity (75% correct in 2AFC), it is
% necessary to select a larger value of W, W=1.5 or 2.  This larger value
% of W provides more powerful decisions and eliminates a source of bias in
% the estimate.

% B. What Level to Try Next in PEST
% You can select the starting value casually.  Typically in
% psychoacoustics, you start with an easy level with near perfect
% discrimination.
% The size of the first step does not matter much.
% PEST does not require the experimenter to know anything about the slope
% of the psychometric function, just its sign.
% Participants may actually find large step sizes disturbing, so generally
% small step sizes are used.  In detection studies, they never make a step
% of more than 4 dB no matter the stepping rule.
% Step sizes after the first are determined by the history of the run.
% Rules:
% 1) on every reversal, halve the step size.
% 2) second step in a given direction is the same as the first.
% 3) fourth and subsequent steps in a given direction are double their
% predecessor (except a limit should be imposed to prevent huge, disturbing
% step sizes).
% 4) the third step is doubled if the previous reversal was not caused by a
% doubling, and it is not doubled if the previous reversal was caused by a
% doubling.
% These rules were developed from intuition and from adjustment of the
% rules over many hours of computer simulation, and the authors give
% heuristic rationales for each rule.

% C. When to Stop and How to Estimate Target Level in PEST
% PEST terminates when the step is less than a predetermined size.
% Choice of the final step size affects the precision of your final
% estimate, but the efficiency weakly.
% Estimate of Lt is the level called for by the last step, not actually
% presenting the last stimulus.  This is less precise than an estimate
% based on some sort of averaging, but the authors argue that it's more
% convenient because they don't have to keep track of the history of the
% run.  It's easy to do with computers these days.



