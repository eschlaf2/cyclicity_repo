function data = process_words(word_counts_file)
% Take output from times_scrape.py and compile into data struct with field
% for each word. Input is three column text file.

% Read in file
f = fopen(word_counts_file);
input = textscan(f, '%s %f %s');
fclose(f);
input{1,3} = str2double(strrep(input{1,3},',','')); % format

% load headers of movie data
path_root = '/Users/emilyschlafly/Work/cyclicity_repo/Movies/movies_vs_words/';
load([path_root,'header_data']);
load([path_root,'movie_word_data']);

words = unique(input{1,1});
data = struct();
for word = words'
    word = word{1};
    mask = strcmp(input{1,1},word);
    data.(word) = sortrows([input{1,2}(mask),log(input{1,3}(mask))],1);
    if ~max(strcmp(upper(word),header_data.categories))
        header_data.categories(end+1) = {upper(word)};
        rows = size(movie_word_data,1);
        for i = (1:length(header_data.years))
            try
                movie_word_data(rows+1,i) = data.(word)(data.(word)(:,1) == ...
                    header_data.years(i),2);
            catch 
                warning(['Year ',header_data.years(i),' not found.'])
            end
        end
    else
        warning(['Word "',word,'" already in dataset']);
    end
end

save('movie_word_data','movie_word_data')
save('header_data','header_data')



