function [toy_data, ss] = create_toy(data_type, varargin)
% Makes sample data. Choose what type of function to look at from
% 'periodic', 'cyclic', 'gaussian', 'data'. Default 'periodic'. 
% Optional arguments:
%     rois:       number of trajectories. default = 9
%     freq:       frequency or number of periods for 'periodic' or 
%                 'cyclic' type. 
%                 default = 5
%     time:       number of time points. default = 100
%     noise:      stdev of noise with respect to stdev 
%                 of signal.
%                 (e.g. noise=0.25 means signal to noise ratio 
%                 ((sigma_signal/sigma_noise)^2) is (1/0.25)^2.
%                 default = 0
%     shift:      maximum time steps between between signals.
%                 default = 5
%     peaks:      number of peaks for 'gaussian' type. default = 7
% Output: 
%     toy_data:   specified data set
%     ss:         expected sort order

%% Parse input
p = inputParser;
    p.CaseSensitive = 0;
    defaultType = 'periodic';
    expectedTypes = {'periodic','cyclic', 'data', 'gaussian','brownian'};
    defaultRois = 9;
    defaultFreq = 5;
    defaultTime = 100;
    defaultnoise = 0;
    defaultShift = 5;
    defaultPeaks = 7;

    addOptional(p,'type',defaultType,...
       @(x) any(validatestring(x, expectedTypes)));
    addParameter(p,'rois',defaultRois, @isnumeric);
    addParameter(p,'freq',defaultFreq);
    addParameter(p, 'time', defaultTime);
    addParameter(p, 'noise', defaultnoise);
    addParameter(p, 'shift', defaultShift, @(x) isnumeric(x));
    addParameter(p, 'peaks', defaultPeaks, @isnumeric);

    parse(p,data_type,varargin{:});
    
    shift = p.Results.shift .* rand(p.Results.rois,1);

data_type = validatestring(p.Results.type, expectedTypes);

%% Generate trajectories
switch data_type
    case 'periodic'
        t = (1:p.Results.time)/p.Results.time;
        shift = shift./p.Results.time;
        line = rand * 100 * sin(2*pi * p.Results.freq * t) + 500;  
    tt = repmat(linspace(0, 1, p.Results.time), p.Results.rois, 1) + ...
        repmat(shift, 1, p.Results.time);
    lines = sin(2*pi * p.Results.freq * tt);
    case 'cyclic'
        T = p.Results.time*100;
        shift = round(100*shift);
        while length(unique(shift)) ~= p.Results.rois
            shift = round(100*p.Results.shift .* rand(p.Results.rois,1));
        end
        tau = zeros(1,ceil(T+max(shift)));
        stepSize = 2*pi*p.Results.freq/T;
        tau(1) = stepSize;
        for i = 2:size(tau,2)
            if sin(tau(i-1))+1<.01 && rand() < .98
                tau(i) = tau(i-1);
            elseif sin(tau(i-1)+4*stepSize) < sin(tau(i-1))
                tau(i) = tau(i-1)+2*stepSize;
            else
                tau(i) = tau(i-1)+6*stepSize;
            end
        end
        lines = zeros(p.Results.rois,p.Results.time);
        for i=1:p.Results.rois
            start = shift(i);
            lines(i,:) = sin(tau(start:100:start+T-1));
        end
    case 'data'
        roi_line; 
        line = smooth(smooth(data_line1));
    case 'gaussian'
        t = (1:p.Results.time);
        line = 30 .* normpdf(t, p.Results.time/2, 1) + 500;
        for i = 1:p.Results.peaks - 1
            line = line + 100 * rand .* ...
                normpdf(t, ...
                randi([2, p.Results.peaks*2 - 2])/(p.Results.peaks*2 - 1) *...
                p.Results.time, randi([1 3]));
        end
    case 'brownian'
        deltas = randn(p.Results.rois,p.Results.time);
        lines = cumsum(deltas,2);
end

if ~exist('lines','var')
    f = fit(p.Results.time/numel(line) .* (1:numel(line)).', ...
        reshape(line, [], 1), 'linear');
    x = repmat((1:p.Results.time), p.Results.rois, 1) + ...
        repmat(shift, 1, p.Results.time);
    lines = reshape(f(x), size(x));
end

%% Add noise and return result
toy_data = lines + p.Results.noise .* ...
    repmat(std(lines, [], 2), 1, p.Results.time) .* randn(size(lines));

[~, ss] = sort(shift, 'descend'); 
