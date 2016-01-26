load('data.mat');
data = movie_data.data;
% data = log(movie_data.data([1:10,12:size(movie_data.data,1)],:));
yrs = movie_data.textdata(1,2:end);
genres = movie_data.textdata(2:end,1);

% Remove film-noir genre (too sparse)
data(11,:) = []; genres(11) = [];

data = inpaint_inf(log(data));
% A = inpaint_inf(A);

% Consider only years in which we have non-zero data
col_mask = ~isnan(sum(data));
data = data(:,col_mask); yrs = yrs(col_mask);

save('processed_movie_data','data')
save('headers', 'genres', 'yrs')