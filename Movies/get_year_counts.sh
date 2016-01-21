#!/bin/bash

genres=$(cat genre_list)
for gnr in $(eval echo $genres); 
    do 
      curl "http://www.imdb.com/search/title?genres=${gnr}&explore=year" | hxnormalize -x | hxselect -i "div.aux-content-widget-3.facets" | w3m -dump -T text/html > year_summaries/$gnr
    done

#curl "http://www.imdb.com/search/title?genres=action&explore=year" | hxnormalize -x | hxselect -i "div.aux-content-widget-3.facets" | w3m -dump -T text/html
