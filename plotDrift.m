function [yA, y0, midbins] = plotDrift(RT,decision,evidence,pm,varargin)
%function [yA, y0, midbins] = plotDrift(RT,decision,evidence,pm,[ntraces,nbins,medianTrace])
%
% Plots the outcomes from the function 'driftdiff'.
%
% Input:
%   - RT, decision, evidence, pm: see 'driftdiff'
%   - [ntraces]: number of traces to show on plot [50]
%   - [nbins]: number of bins for histograms [20]
%   - [medianTrace]: highlight median trace [false]
%
% Fabrice Luyckx, 24/3/2017 (adapted from scripts by Chris Summerfield)

%% DEFAULT VALUES

optargs = {50,20,false};

% Now put these defaults into the valuesToUse cell array,
% and overwrite the ones specified in varargin.
specif = find(~cellfun(@isempty,varargin)); % find position of specified arguments
[optargs{specif}] = varargin{specif};

% Place optional args in memorable variable names
[ntraces,nbins,medianTrace] = optargs{:};

%% Drift particles

a   = pm.upperbound;
z   = mean(pm.bias);
d   = pm.deadline;

hold on;

% Plot first 50 (or less) trials
plottrace   = min(pm.trials,ntraces);
sample      = Shuffle(1:pm.trials);
sample      = sample(1:plottrace);
plot(evidence(sample,:)','linewidth',1,'Color',[.6 .6 .6]);

% Plot boundaries
plot([1 d],[0 0],'linewidth',1,'linestyle','-','color','k');
plot([1 d],[z z],'linewidth',1,'linestyle','--','color','k');
plot([1 d],[a a],'linewidth',1,'linestyle','-','color','k');

margprop    = 1.2;
marg        = a*margprop - a;
ylim([0-marg*1.05 a+marg*1.05]);
xlim([1 d]);

% Axis labels
xlabel('Time (in ms)','FontSize',16);
set(gca,'Ytick',[0 mean(z) a],'Yticklabel',{num2str(0) 'z' 'a'},'FontSize',14);

% Get median trial
if medianTrace
    med     = median(RT,'omitnan');
    m       = find(RT==round(med));
    mRT     = m(1);
    plot(evidence(mRT,:),'linewidth',2,'color',[.8 0 0]);
end

%% RT distributions

% Get 20 bins of data
binedge = linspace(0,pm.deadline,nbins+1);
midbins = binedge(1:end-1) + diff(binedge)/2;
for b = 1:length(binedge)-1
    yA(b) = sum(RT(decision==1) >= binedge(b) & RT(decision==1) < binedge(b+1));
    y0(b) = sum(RT(decision==-1) >= binedge(b) & RT(decision==-1) < binedge(b+1));
end

% Rescale data
allY    = [yA y0];
scaleY  = ((allY - min(allY))./(max(allY)-min(allY))).*marg;
sYa     = scaleY(1:nbins);
sY0     = scaleY(nbins+1:end);

% Plot bar distributions
barcolz = [1 0.8 0.45];
for b = 1:length(binedge)-1
    patch([binedge(b);binedge(b+1);binedge(b+1);binedge(b)],[0; 0; sYa(b); sYa(b)]+a,barcolz);
    patch([binedge(b);binedge(b+1);binedge(b+1);binedge(b)],[0; 0; -1*sY0(b); -1*sY0(b)],barcolz);
end

% Get continuous distribution
distXa = zeros(1,100);
distYa = zeros(1,100);
distX0 = zeros(1,100);
distY0 = zeros(1,100);

if length(find(sYa == 0)) < 15
    tmpFig  = figure;
    hA      = histfit(RT(decision == 1),min(length(RT(decision == 1)),nbins),'kernel');
    distXa  = hA(2).XData;
    distYa  = hA(2).YData;
    close(tmpFig)

    % Plot mode of distribution
    plot([distXa(distYa == max(distYa)) distXa(distYa == max(distYa))],[a a+marg*1.05],'linewidth',3,'linestyle','-','color','g');
end

if length(find(sY0 == 0)) < 15
    tmpFig = figure;
    h0      = histfit(RT(decision == -1),min(length(RT(decision == -1)),nbins),'kernel');
    distX0  = h0(2).XData;
    distY0  = h0(2).YData;
    close(tmpFig)

    % Plot mode of distribution
    plot([distX0(distY0 == max(distY0)) distX0(distY0 == max(distY0))],[0-marg*1.05 0],'linewidth',3,'linestyle','-','color','g');
end

% Rescale distributions
allYdist    = [distYa distY0];
scaleY      = ((allYdist - min(allYdist))./(max(allYdist)-min(allYdist))).*marg;
distYa      = scaleY(1:length(distYa));
distY0      = scaleY(length(distYa)+1:end);

% Plot continuous distributions
plot(distXa,distYa+a,'LineWidth',2,'Color','r');
plot(distX0,-1*distY0,'LineWidth',2,'Color','r');

end
