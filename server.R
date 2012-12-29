################################################################################
##
## Server-side script for the game
##
################################################################################
library(shiny)
library("plyr")
library("ggplot2")


## take time to give a unique filename
now <- gsub(" ", "_", Sys.time())



## build data.frame
history<- data.frame(Person = NA, Time = NA)
history$Person <- factor(history$Person, levels = persons)
filename = paste("./dataframes/drinks-history-", now, ".RData", sep = "")
save(history, file = filename)


source("server-functions.R")

## time when game was started
started_game_at <- as.numeric(Sys.time())

# Define server logic
shinyServer(function(input, output) {
  
  
  ## function which changes if either the person was changed or the again button was pushed
  ## this function can be called in other reactive functions
  ## the result is, that the other functions are updated for every change in person / again-button push
  ## this is so ugly and I feel bad about it
  something_happened <- reactive(function(){
    c(input$person, input$again)
  })

  update <- function(){
    something_happened()
    update_history()
  }
  observe(update)

  
  update_history <- function(){
    history <- get_history(filename)
    time_passed <- Sys.time() - started_game_at
    new_drinks <-  c(input$person,  time_passed)
    history <- rbind(history, new_drinks)
    ## delete the first NA
    history <- na.omit(history)
    save(history, file = filename)
  }


  
  output$text <- reactiveText(function() {
    something_happened()
    last_row <- get_history(filename, only_last = TRUE)
    paste(last_row[1], "shall drink")
  })

  output$history <- reactiveTable(function(){
    something_happened()
    history <- get_history(filename)
    as.matrix(na.omit(history))
  })

  output$timeline <- reactivePlot(function(){
    something_happened()
    plot_history(filename)
  })

  ## DEBUG OUTPUT
  output$debug_timeline <- reactiveTable(function(){
    something_happened()
    history_to_timeline(get_history(filename))
  })

  output$debug_time <- reactiveText(function(){
    something_happened()
    history <- get_history(filename)
   #  max(history$Time)
    str(history)
  })

  output$leaderboard <- reactivePlot(function(){
    something_happened()
    history <- get_history(filename)
    barplot(table(history$Person))
  })
  
})
