function S = dstat(x)
% Descriptive statistics on a vector x
%
% USAGE: S = stat(x)
% INPUT: x - vector
% OUTPUT: structure S.{mean, var, min, max}

S.mean = mean(x);
S.var = var(x);
S.min = min(x);
S.max = max(x);