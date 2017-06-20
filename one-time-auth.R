
## From: http://pablobarbera.com/code/streamR.html

rm(list=ls())
setwd("~/Rprojects/GetTwitterData_Shiny_8/")

library(ROAuth)
library(streamR)

requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "baFpoWX8GFEIFvrgOifrXSF1I"
consumerSecret <- "7sssvfp3eoCKfEdl7tmB4Tybk2GKLqnS5891JELYehb4Yce1qG"
my_oauth <- OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, 
                             requestURL = requestURL, accessURL = accessURL, authURL = authURL)

my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
save(my_oauth, file = "my_oauth.Rdata")