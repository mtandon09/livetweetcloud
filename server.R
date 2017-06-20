## ----------------------------------------------------
## Created by Mindul Consulting LLC
## Author : Mayank Tandon, Bhupendra Tandon
## Date   :25-Jul-2014
## ----------------------------------------------------

require(shiny)
require(streamR)
require(tm)
require(SnowballC)

source("wordcloud-helpers.R")

myRefreshRate <- 3 # in seconds

tweetFileName <- "www/data/tweets.json"
tweetFileName.log <- "www/data/tweets.log"
# wordDataFile <- "www/data/word.data.csv"
wordDataFile.default <- "www/data/word.data.default.csv"
includeScript("www/libraries/d3.min.js")
includeScript("www/libraries/d3.layout.cloud.js")
includeScript("www/libraries/my-wordcloud-binding.js")

queryText <- ""
collectionTime <- 0
refreshRate <- 2 # seconds
tweetInfo <- data.frame()

shinyServer(function(input, output,session) {
  #   alldata <- data.frame(text=character(),size=numeric(),row.names=NULL)

  if (file.exists(wordDataFile.default)) {
    #     print("Loading default file")
    #     session$sendCustomMessage(type = "updateWordcloud",list("startMessage",wordDataFile))
    output$myWordCloud <- renderWordcloud(wordDataFile.default)
    output$tweetTable <- renderDataTable(read.csv(wordDataFile.default))
#     output$tweetTableMsg <- renderText("")
  }
#   output$tweetTable <- reactive(renderTable(data.frame()))
#   output$tweetTableMsg <- reactive(renderText("Downloading tweets... Check back after the word cloud is done."))
  
  observe({    
    queryText <- isolate(input$query)
    collectionTime <- isolate(input$collectTime)
    
#     tableLoadMsg <- reactive(
#       renderText("[Loading message]")
#       )
    
#     tableShow <- reactive(
#       renderDataTable(tweetData)
#     )
    
    if (input$submitButton != 0) {
      if (file.exists(tweetFileName)) {
        #   print("Removing File")
        file.remove(tweetFileName)
      }
      
      startTime <- Sys.time()
      endTime <- startTime + collectionTime
      lastRan <- 0
      
#       output$tweetTable <- renderTable(tweetInfo)
#       output$tweetTableMsg
      output$tweetTable <- renderDataTable(tweetInfo)      
      alldata <- data.frame(text=character(),size=numeric())
      timemsg <- paste("Started at: ",startTime,"; Ending at ",endTime,sep="")
      print(timemsg)
      
      msg <- paste("Collecting data... [",timemsg,"]",sep="")
      session$sendCustomMessage(type = "statusMessage",msg)
      
      myCmd <- paste("Rscript","capture-tweets.R",queryText,collectionTime,tweetFileName,"2>&1 | tee",tweetFileName.log,sep=" ")
      system(myCmd,wait=FALSE,ignore.stderr = TRUE)
      
      numtweets.last <- 0
      while(Sys.time() < endTime) {        
        currTime <- as.integer(Sys.time())
        if ((currTime - as.integer(startTime)) %% refreshRate == 0) {
          if(currTime != lastRan) {
            lastRan <- currTime
            
            twData <- readAndCountTweets(tweetFileName,queryText)
            numtweets <- twData[[1]]
            mydata <- twData[[2]]
            tweetInfo <- twData[[3]]
            
            newtweets <- numtweets - numtweets.last
            numtweets.last <- numtweets
            
            if (newtweets < 2) {
              next
            }
            
            freqdata <- mydata[with(mydata,order(-size))[1:min(100,nrow(mydata))],]            
            myJSmsg <- freqdata
            session$sendCustomMessage(type = "updateWordcloud",list(freqdata,numtweets))
          }
        }
      }
      msg <- paste("Done! This wordcloud represents ",numtweets," tweets between ",startTime," and ",endTime,".",sep="")
      session$sendCustomMessage(type = "statusMessage",msg)
      output$tweetTable <- renderDataTable(tweetInfo)
    }
  })
})