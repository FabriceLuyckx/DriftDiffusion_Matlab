%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Drift diffusion tutorial (Luyckx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%addpath(~/Location/of/your/function)

%% Default model

pm = struct; % create empty structure
[RT,decision,evidence,pm] = driftdiff(pm); % run default simulation

% Plot outcome with custom function 'plotDrift'
figure;
plotDrift(RT,decision,evidence,pm);

%% Standard model for comparison

pm = struct; % empty structure
pm.driftrate = 1; % evidence for option A

[RT,decision,evidence,pm] = driftdiff(pm);
figure; plotDrift(RT,decision,evidence,pm,20);

%% Changing drift rate

pm = struct; % empty structure
pm.driftrate = 1; % evidence for option A

figure; 

% Default model
[RT,decision,evidence,pm] = driftdiff(pm);
subplot(2,1,1); plotDrift(RT,decision,evidence,pm,20); 
title(['v = ' num2str(pm.driftrate(1))]);

% Higher drift model
pm.driftrate = 2; % more evidence for option A
[RT,decision,evidence,pm] = driftdiff(pm);
subplot(2,1,2); plotDrift(RT,decision,evidence,pm,20); 
title(['v = ' num2str(pm.driftrate(1))]);

%% Changing the drift rate SD

pm = struct; % empty structure
pm.driftrate = 1; % evidence for option A

figure; 

% Lower noise model
pm.noise = 5; % decrease noise level
[RT,decision,evidence,pm] = driftdiff(pm);
plotDrift(RT,decision,evidence,pm,20); 
title(['eta = ' num2str(pm.noise(1)) ' instead of ' num2str(15)]);

%% Changing the bounds

pm = struct; % empty structure
pm.driftrate = 1; % evidence for option A

figure; 

% Default model
[RT,decision,evidence,pm] = driftdiff(pm);
subplot(2,1,1); 
plotDrift(RT,decision,evidence,pm,20); 
title(['a = ' num2str(pm.upperbound(1))]);

% Decreased bounds model
pm.upperbound = 300; % decrease bound a
pm.bias = pm.upperbound/2; % keep starting point in the middle!

[RT,decision,evidence,pm] = driftdiff(pm);
subplot(2,1,2); 
plotDrift(RT,decision,evidence,pm,20); 
title(['a = ' num2str(pm.upperbound(1))]);

%% Changing the bias

pm = struct; % empty structure

figure; 

% Biased model
pm.bias = 400; % bias for option A
pm.biasrange = 50; % bias ranges from 375 - 425
[RT,decision,evidence,pm] = driftdiff(pm);
plotDrift(RT,decision,evidence,pm,20); 
title(['bias = ' num2str(round(mean(pm.bias)))]);

%% Changing the non-decision time

pm = struct; % empty structure
pm.driftrate = 1; % evidence for option A

figure; 

% Default model
[RT,decision,evidence,pm] = driftdiff(pm);
subplot(2,1,1); 
plotDrift(RT,decision,evidence,pm,20); 
title(['t_0 = ' num2str(pm.nondectime(1))]);

% Delayed model
pm.nondectime = 200; % wait 200 ms before integration
pm.ndcrange = 25; % waiting time varies between 175 and 225 ms

[RT,decision,evidence,pm] = driftdiff(pm);
subplot(2,1,2); 
plotDrift(RT,decision,evidence,pm,20); 
title(['t_0 = ' num2str(round(mean(pm.nondectime)))]);