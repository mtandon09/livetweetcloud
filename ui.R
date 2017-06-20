## ----------------------------------------------------
## Created by Mindul Consulting LLC
## Author : Mayank Tandon, Bhupendra Tandon
## Date   :25-Jul-2014
## ----------------------------------------------------

library(shiny)
library(streamR)
library(tm)
library(SnowballC)

source("wordcloud-helpers.R")
includeScript("www/libraries/d3.min.js")
includeScript("www/libraries/d3.layout.cloud.js")
includeScript("www/libraries/my-wordcloud-binding.js")
#     includeScript("www/libraries/my-wordcloud-helpers.js")

# shinyUI(
#   fluidPage(
#     titlePanel("Twitter Word Cloud"),
#     fluidRow(
#       column(2,"sidebar"),
#       column(10,"main")
#       )
#   )
# )
shinyUI(
  fluidPage(
#     includeScript("www/libraries/d3.js"),
#     includeScript("www/libraries/d3.layout.cloud.js"),
#     includeScript("www/libraries/my-wordcloud-binding.js"),
#     includeScript("www/libraries/my-wordcloud-helpers.js"),
    
    titlePanel("Twitter Word Cloud"),
    sidebarLayout(
      sidebarPanel(
        h3("Generate a word cloud by collecting live Twitter data"),
        h6("This tool will create a word cloud using text from live tweets
           where the size of each word represents the how often it was mentioned
           with the the keyword entered.  Overall, the word cloud is sort of a representation
           of what people are talking about in the context provided by the keyword.
           "),
        br(),
        h6("Enter a keyword for the tweets and the amount of time to collect data.
           "),
        h5("Enter a word or phrase to look for:"),
        textInput("query",label="",value="cool"),
        br(),
        numericInput("collectTime",label="Time to capture tweets for: (secs)",value=30),
        br(),
        br(),
        actionButton("submitButton","Go!"),
        br(),
        br(),
        p(id="tweetStatus")
      ),
#       mainPanel(img(src="wordcloud.png"))
       mainPanel(
         tabsetPanel(
           tabPanel("Word Cloud",
                    p(style="position: right: 0; top: 0", id="status"),
                    wordcloudOutput("myWordCloud")),
           tabPanel("Tweets",
                    textOutput("tweetTableMsg"),
#                     tableOutput("tweetTable"))
                    dataTableOutput("tweetTable"))
         )
       )
    )

))