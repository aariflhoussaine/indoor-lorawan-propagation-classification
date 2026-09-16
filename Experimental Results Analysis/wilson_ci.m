function [ci_low, ci_high] = wilson_ci(successes, trials, confidence)
% WILSON_CI  Wilson score confidence interval for a binomial proportion.
%
% Used here to compute a confidence interval on Packet Delivery Ratio
% (PDR = received / expected packets), treating each expected packet as
% a Bernoulli trial (received vs. not received). The Wilson interval is
% preferred over the simple normal approximation because it remains
% well-behaved even when the proportion is close to 0 or 1, and does not
% require successes/trials to be large.
%
% INPUTS:
%   successes  - number of packets received (nb_recus)
%   trials     - number of packets expected (nb_attendus)
%   confidence - confidence level, e.g. 0.95 for a 95% CI (default 0.95)
%
% OUTPUTS:
%   ci_low, ci_high - lower and upper bounds of the confidence interval,
%                      as proportions in [0, 1] (multiply by 100 for %)

if nargin < 3
    confidence = 0.95;
end

z = norminv(1 - (1 - confidence) / 2);  % e.g. 1.96 for 95%
p_hat = successes / trials;
n = trials;

denom = 1 + (z^2) / n;
center = (p_hat + (z^2) / (2 * n)) / denom;
margin = (z / denom) * sqrt((p_hat * (1 - p_hat) / n) + (z^2) / (4 * n^2));

ci_low  = max(0, center - margin);
ci_high = min(1, center + margin);
end
