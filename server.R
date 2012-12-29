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

drinks_history<- matrix(ncol = 2, nrow = 0)
colnames(drinks_history) <- c("Person",  "Time")
drinks_history <- as.data.frame(drinks_history)
filename = paste("./dataframes/drinks-history-", now, "csv", sep = "")
write.csv(drinks_history, filename, row.names = FALSE)


source("server-functions.R")

## time when game was started
started_game_at <- as.numeric(Sys.time())

# Define server logic
shinyServer(function(input, output) {
  
  
  ## function which updates everything
  update <- function(){
    input$again
    history <- update_history()
  }

  update_history <- function(){
    person <- input$person
    drinks_history <- read.csv(filename, stringsAsFactors = FALSE, header = TRUE)
    time_passed <- Sys.time() - started_game_at
    new_drinks <-  c(person,  time_passed)
    drinks_history <- rbind(drinks_history, new_drinks)
    colnames(drinks_history) <- c("Person",  "Time")
    write.csv(drinks_history, file = filename, row.names = FALSE)
  }


  ## data set is updated for every change of person or by hitting "Drink again"
  observe(update)

  output$text <- reactiveText(function() {
    input$again
    last_row <- get_history(filename, only_last = TRUE)
    paste(last_row[1], "shall drink")
  })

  output$history <- reactiveTable(function(){
    ## the function shall react if "Drink again" was clicked
    input$again
    history <- get_history(filename)
  })

  output$timeline <- reactivePlot(function(){
    input$again
    plot_history(filename)
  })

  ## DEBUG OUTPUT
  output$debug_timeline <- reactiveTable(function(){
    input$person
    input$again
    history_to_timeline(get_history(filename))
  })

  output$debug_time <- reactiveText(function(){
    history <- get_history(filename)
    max(history$Time)
  })
  
})
