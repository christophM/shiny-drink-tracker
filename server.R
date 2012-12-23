################################################################################
##
## Server-side script for the game
##
################################################################################
library(shiny)
library("plyr")
library("ggplot2")

drinks <- c("Bier", "Vodka", "Rum")


## take time to give a unique filename
now <- gsub(" ", "_", Sys.time())

drinks_history<- matrix(ncol = 3, nrow = 0)
colnames(drinks_history) <- c("Person", "Drink", "Time")
drinks_history <- as.data.frame(drinks_history)
filename = paste("./dataframes/drinks-history-", now, "csv", sep = "")
write.csv(drinks_history, filename, row.names = FALSE)


source("server-functions.R")

## time when game was started
started_game_at <- as.numeric(Sys.time())

# Define server logic
shinyServer(function(input, output) {
  
  ## data set is updated for every change of person or by hitting "Drink again"
  observe(update)

  output$text <- reactiveText(function() {
    input
    last_row <- get_history(only_last = TRUE)
    paste(last_row[1], "muss", last_row[2], "trinken")
  })

  output$history <- reactiveTable(function(){
    ## the function shall react if "Drink again" was clicked
    input$again
    history <- get_history()
  })

  output$timeline <- reactivePlot(function(){
    input$person
    input$again
    plot_history()
  })

  ## DEBUG OUTPUT
  output$debug_timeline <- reactiveTable(function(){
    input$person
    input$again
    history_to_timeline(get_history())
  })

  ## output$debug_time <- reactiveText(function(){
  ##   history <- get_history()
  ##   max(history$Time)
  ## })
  
})
