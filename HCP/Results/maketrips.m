function [trips] = maketrips(PERMS, CYCLE)

N = length(PERMS{1});
trips = zeros(N,N,N);
[a, b, c] = ndgrid(1:N, 1:N, 1:N);

for p = (1:length(PERMS))
    perm = PERMS{p};
    
    for i = (1:N-2)
        for j = (i+1:N-1)
            wheel = [perm;circshift(perm,-i,2);circshift(perm,-j,2)];
            new_trips = wheel(:,1:end-j)';
            if CYCLE
                new_trips = cycle_trips(new_trips);
            end
            inds = sub2ind(size(trips),...
                new_trips(:,1), new_trips(:,2), new_trips(:,3));
            trips(inds) = trips(inds) + 1;
        end
    end
end
trips = [a(:) b(:) c(:) trips(:)];
trips = trips(trips(:,4) > 0,:);
        
end

function [trips] = cycle_trips(trips)
[~,min_loc] = min(trips(:,1:3),[],2);
shift = 1 - min_loc;
for i = (1:size(trips,1))
    trips(i,1:3) = circshift(trips(i,1:3),shift(i),2);
end
end