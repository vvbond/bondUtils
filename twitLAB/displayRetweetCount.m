function displayRetweetCount(S)

for ii=1:length(S)
    try
        disp(S{ii}.retweet_count)
    end
end