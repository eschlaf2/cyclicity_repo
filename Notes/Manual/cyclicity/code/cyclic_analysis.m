function [eig_phases, eig_perm, sorted_lead_matrix, eig_vals] = ...
    cyclic_analysis(data_file, norm_method, p)
% Performs cyclic analysis on data_file using normalization norm_method,
% one of 'z-score' or 'quad' (default 'quad'), on eigenvector p (default
% 1). 

% ************************************************************************
% Begin input parser
% ************************************************************************
P = inputParser;

defaultNorm_method = 'quad';
expectedNorms = {'quad','z-score'};

addRequired(P,'data_file');
addOptional(P,'norm_method',defaultNorm_method,...
    @(x) any(validatestring(x,expectedNorms)));
addOptional(P,'p',1);

switch nargin
    case 1
        parse(P,data_file);
    case 2
        parse(P,data_file,norm_method);
    otherwise
        parse(P,data_file,norm_method,p);
end

data_file = P.Results.data_file;
p = P.Results.p;
norm_method = P.Results.norm_method;
% ************************************************************************

% parse input
% norm_methods = {'z-score', 'quad'};
% switch nargin
%     case 1
%         p = 1;
%     case 2
%         validatestring(norm_method, norm_methods);
%         p = 1;
%     case 3
%         if ischar(norm_method)
%             validatestring(norm_method, norm_methods);
%         else
%             display('Setting norm_method to default.')
%         end
%         if ~isnumeric(p)
%             warning(['Input value p=',p,' is invalid. Setting p=1.'])
%             p = 1;
%         end
%     otherwise
%         error('Wrong number of arguments');
% end

if ischar(data_file)
    data = importdata(data_file);
else
    data = data_file;
end
% data = integration_filter(data);

switch norm_method
    case 'z-score'
        normed_data = z_score_norm(data);
    case 'quad'
        normed_data = quad_norm(data);
end

lead_matrix = create_lead(normed_data);
[eig_phases, eig_perm, sorted_lead_matrix, eig_vals] = ...
    sort_lead(lead_matrix, p);

end

function [y] = integration_filter(x)
    y = zeros(size(x));
    for i = 1:numel(x(:,1))
        y(i,:) = smooth(x(i,:));
    end
end

function [normed_Z] = quad_norm(Z)
% Normalize vector(s) Z so that the quadratic variation is equal to 1. See
% Frobenius norm

% time_dim = size(Z,2);
z_adjusted = match_ends(Z);
z_diff = (z_adjusted-circshift(z_adjusted,1,2));
normf = sqrt(diag(z_diff*z_diff'));
normed_Z = (z_adjusted'/(diag(normf)))';
normed_Z = mean_center(normed_Z);

end 

function [normed_Z] = z_score_norm(Z)
% Normalize vector(s) Z using Z-score-scaling - ?=0, ?=1.

    time_steps = size(Z,2);
    Z = match_ends(Z);
%     t = linspace(0,1,time_steps);
%     Z=Z-(Z(:,time_steps)-Z(:,1))*t;
    Z = mean_center(Z);
    normed_Z = repmat(var(Z, [], 2).^(-1/2), 1, time_steps) .* Z;
end

function matched_Z = match_ends(Z)
% Linearly adjusts a matrix (set of vectors) Z so that the end points match
% the starting points - Z(:,1) == Z(:,end)
n = size(Z,2);
matched_Z = Z - (Z(:,n) - Z(:,1)) * linspace(0,1,n);
end

function centered_Z = mean_center(Z)
% Shifts vector(s) Z so that mean == 0.
centered_Z = Z - repmat(mean(Z, 2), 1, size(Z, 2));
end

function [lead_matrix] = create_lead(normed_Z)

    [N, time_steps] = size(normed_Z);

    % Create matrix of areas a
    lead_matrix=zeros(N);
    for ii=1:N;
        lead_matrix(ii,ii)=0;
        for jj=ii+1:N;
          x=normed_Z(ii,:); y=normed_Z(jj,:);
          lead_matrix(ii,jj)= time_steps * ... % x * (diff([y(end), y])');
              (x * (diff([y(end),y])') - y * (diff([x(end),x])'));
          lead_matrix(jj,ii)=-lead_matrix(ii,jj);
        end;
    end;
end

function [phases, perm, slm, evals]=sort_lead(a, varargin)
% The first input should be the matrix to be sorted, the second is the
% phase or eigenvector to use (default 1). The third, if given, should be
% the title of an ROI to be used as a baseline.
% On July 2 I changed the output so that phases outputs an angle rather
% than the associated complex number and the lowest phase is always zero.
% On July 14 I changed the output so that a chosen ROI can be used as a
% baseline.
% Note, there is no angle adjustment in this version.

% 2/2 testing phases = phases (:,p);

%% **************************************************************
% Begin input parser
% **************************************************************
P = inputParser;
defaultP = 1;

addRequired(P,'a',@isnumeric)
addOptional(P,'p',defaultP)

parse(P,a,varargin{:});
a = P.Results.a;
p = P.Results.p;
% **************************************************************
%%

    [phases,evals]=eig(a);
     
     phases = phases(:,2*p-1); % added 2/2 - testing
     evals = diag(evals);
%      sorted_ang = sort(mod(angle(phases(:,p)),2*pi)); 2/2
     sorted_ang = sort(mod(angle(phases),2*pi));
     [~, shift] = max(abs(diff([sorted_ang; sorted_ang(1) + 2*pi])));
     if shift == numel(phases)
         shift = 1; 
     else
         shift = shift + 1;
     end
     shift = sorted_ang(shift);
%      shift = pi - median(mod(angle(u(:,1).'), 2*pi));
% 	 [phases,perm]=sort(mod(mod(angle(phases(:,p).'), 2*pi) - shift,
% 	 2*pi)); 2/2
	 [~,perm]=sort(mod(mod(angle(phases.'), 2*pi) - shift, 2*pi));
     slm=a(perm,perm);
 
%      Phase adjust
%     switch nargin
%         case 4
%             ROIS = varargin{1};
%             baseroi = varargin(2);
%             try
%                 angle_adjust = ph(perm == find(strcmp([ROIS(:,1)], baseroi)));
%             catch ME
%                 warning('baseroi not found. Input ignored.')
%                 [phases, perm, slm, evals] = sort_lead(a);
%                 return
%             end
%         case 3
%             error('Optional arg 1 should be the ROIS; optional arg 2 should be base roi')
%         case 2
%             angle_adjust = min(ph);
%         case 1
%             p = 1;
%         otherwise
%             error('Too many arguments')
%     end

%      phases = phases - ones(size(phases)) .* angle_adjust;
%      phases = phases(:,1); 2/2
%      eig_vect = eig_vect(permutation,:);
end
