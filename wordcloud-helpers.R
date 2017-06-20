## ----------------------------------------------------
## Created by Mindul Consulting LLC
## Author : Mayank Tandon, Bhupendra Tandon
## Date   :25-Jul-2014
## ----------------------------------------------------
## From: https://github.com/jcheng5/shiny-js-examples/blob/master/output/linechart.R

# Import libraries

initializeData <- function() {
  defaultTweets <- load("data/tweets.default.Rdata")
  return(defaultTweets)
}

collectData <- function(queryText, refreshTime,twFileName) {  
  # load handshake details (generated with one-time-auth.R)
  load("my_oauth.Rdata")
  filterStream(file.name = twFileName,
               track = queryText,
               timeout = refreshTime,
               language = "en",
               oauth = my_oauth)
}

readAndCountTweets <- function(twFileName,qry) {  
  numWords <- 100
  d <- data.frame(text=character(),size=numeric())
  # Parse twFileName into dataframe
  result <- tryCatch({
    tweets.df <- parseTweets(twFileName, simplify = FALSE)
  }, error = function(err) {
    print(err)
    return(list(0,d))
    return(list(0,d,data.frame()))
  },finally = {
    if (! exists("tweets.df")) {
      return(list(0,d,data.frame()))
    }
    
  })
  
  numtweets <- nrow(tweets.df)
  myformat <- "%a %b %d %H:%M:%S +0000 %Y"
  #   tweets.df$created_at_DT <- strptime(tweets.df$created_at, myformat)
  startTime <- strptime(tweets.df$created_at[1], format=myformat,tz="")
  stopTime <- strptime(tweets.df$created_at[numtweets], format=myformat,tz="")
  timespan <- as.character(difftime(stopTime,startTime,units="mins"))
#     browser()
  
  # Grab tweet text and filter it for counting
  tweets.text <- gsub("[^[:alnum:]///' ]", "", tweets.df[,1]) # remove everything that's not alphanumeric
  tweets.text <- gsub(qry, " ", tweets.text, ignore.case=TRUE) # remove 'USPS' because we know that's going to be there
  tweets.corpus <- Corpus(DataframeSource(data.frame(tweets.text))) # Make Corpus object for tm_map function ('tm' package)
  tweets.corpus <- tm_map(tweets.corpus, removePunctuation) # remove punctuation
  # tweets.corpus <- tm_map(tweets.corpus, tolower) # make lower case (to count all cases of a word)
  tweets.corpus <- tm_map(tweets.corpus, function(x) removeWords(x, stopwords("english"))) # use the tm packages common words list to remove common words like a, the, like, etc
  
  # Count the frequencies
  # This keeps failing if I use the "tolower" function a few lines above
  # Cannot replicate on Mac Pro at work, so it's a local installation/dependency issue on my laptop, but I can't track it
  tdm <- TermDocumentMatrix(tweets.corpus) # Convert to a term document matrix for counting
  m <- as.matrix(tdm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(text = as.character(names(v)),size=as.numeric(v),row.names=NULL)
  if(nrow(d) > numWords) {
    d<- d[1:numWords,]
  }
#   return(list(numtweets,d))
  tweetFields <- c("name","text","created_at","retweet_count","followers_count","geo_enabled","lat","lon")
  tweets.df.return <- tweets.df[,tweetFields]
  colnames(tweets.df.return) <- c("Username","Tweet Text","Time","Num Followers","Loc Enabled","Latitude","Longitude")
  return(list(numtweets,d,tweets.df[,tweetFields]))  
#   d <- lapply(d,function(x) type.convert(as.character(x)))
}
  
# To be called from ui.R
# wordcloudOutputs <- function(inputId, width="100%", height="100%") {
wordcloudOutput <- function(inputId, width="900", height="800") {
  style <- sprintf("width: %s; height: %s;",
                   validateCssUnit(width), validateCssUnit(height))
  
  tagList(
    # Include CSS/JS dependencies. Use "singleton" to make sure that even
    # if multiple lineChartOutputs are used in the same page, we'll still
    # only include these chunks once.
    singleton(tags$head(
      tags$script(src="libraries/d3.js"),
      tags$script(src="libraries/d3.layout.cloud.js"),
      tags$script(src="libraries/my-wordcloud-binding.js")
    )),
    div(id=inputId, class="d3-wordcloud", style=style,
        tag("svg", list())
    )
  )
}

renderWordcloud <- function(expr, env=parent.frame(), quoted=FALSE) {
#   print(expr)
  function(){gsub("www/","",expr)}
  
}


