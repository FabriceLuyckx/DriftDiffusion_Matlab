function [RT,decision,evidence,pm] = driftdiff(pm)
%function [RT,decision,evidence,pm] = driftdiff(pm.['trials','driftrate','noise','zeropoint','bias','biasrange','upperbound','nondectime','ndcrange','deadline','leak','lambda'])
%
% Simulate drift diffusion process (+ optional plot).
%
% Input:
%   - pm
%       - trials: number of trials [1000]
%       - driftrate: stimulus quality [0]
%       - noise: SD of driftrate [15]
%       - zeropoint: drift criterion [0]
%       - bias: prior bias[300]
%       - biasrange: range of bias [0]
%       - upperbound: upper bound a [600]
%       - nondectime: non-decision time [0]
%       - ndcrange: range of non-decision time [0]
%       - deadline: length of epoch in ms [1000]
%       - leak: decay of information, reasonably between 0 - 1 [0]
%       - lambda: increase rate (mean DV*lambda) [0]
%
% Output:
%   - RT: reaction times for each trial
%   - decision: choice (-1,0,1)
%   - evidence: evidence trace for each trial
%   - pm: adjusted pm structure
%
% Fabrice Luyckx, 23/3/2017 (adapted from scripts by Chris Summerfield)

%% DEFAULT VALUES

paramnames  = {'trials','driftrate','noise','zeropoint','bias','biasrange','upperbound','nondectime','ndcrange','deadline','leak','lambda'};
paramvals   = {1000,0,15,0,300,0,600,0,0,1000,0,0};
structnames = fields(pm);

for i = 1:length(paramnames)
    if sum(strcmp(paramnames{i},structnames)) == 0 % field doesn't exist
        pm = setfield(pm,paramnames{i},paramvals{i});
    else
        if isempty(getfield(pm,paramnames{i})) % field has no content
            pm = rmfield(pm,paramnames{i});
            pm = setfield(pm,paramnames{i},paramvals{i});
        end
    end
end

%% Initialise

RT          = nan(pm.trials,1);
decision    = zeros(pm.trials,1);
evidence    = zeros(pm.trials,pm.deadline);

% Set drift rate
if length(pm.driftrate) == 1
    pm.driftrate = pm.driftrate.*ones(pm.trials,1);
end

% Set zeropoint
if length(pm.zeropoint) == 1
    pm.zeropoint = pm.zeropoint.*ones(pm.trials,1);
end

% Draw nondecision time from uniform distribution
pm.nondectime = pm.nondectime.*ones(pm.trials,1) - pm.ndcrange/2 + (pm.ndcrange*rand(pm.trials,1));

% Determine bias from uniform distribution
pm.bias = pm.bias.*ones(pm.trials,1) - pm.biasrange/2 + (pm.biasrange*rand(pm.trials,1));

% Evidence starts as bias
DV  = pm.bias;

%% Simulate drift process

for t = 1:pm.deadline

    % Add increment
    inc = pm.driftrate + pm.zeropoint + randn(pm.trials,1)*pm.noise; % increment
    inc = inc.*(t>pm.nondectime); % only add increment after nondecision time has passed
    DV  = DV + inc - (pm.leak*sign(DV)) + (mean(DV)*pm.lambda); % add leak and increase rate

    % Log trials where bound is reached (a or 0)
    RT(DV > pm.upperbound & decision == 0) = t;
    RT(DV < 0 & decision == 0)          = t;

    % Log decision
    decision(DV > pm.upperbound & decision == 0)    = 1;
    decision(DV < 0 & decision == 0)                = -1;

    % Log evidence
    evidence(:,t)               = DV;
    evidence(decision == 1,t)   = pm.upperbound;
    evidence(decision == -1,t)  = 0;

end

end
