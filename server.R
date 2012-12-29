################################################################################
##
## Server-side script for the game
##
################################################################################
library("plyr")
library("ggplot2")
library("directlabels")

## take time to give a unique filename
now <- gsub(" ", "_", Sys.time())


## build data.frame
history <- data.frame(Person = NA, Time = NA)
history <- data.frame(Person = character(0), Time = numeric(0))

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
    if(input$person != "[choose person]"){
      history <- get_history(filename)
      time_passed <- Sys.time() - started_game_at
      new_drinks <-  c(input$person,  time_passed)
      
      ## add new drinks
      history[nrow(history) + 1, ] <- new_drinks
      save(history, file = filename)
    }
  }


  
  output$text <- reactiveText(function() {
    something_happened()

    text <- sample(x = c("Prost", "Cheers", "Salute", "Kanpai", "Gan Bei", "Salud", "Skal", "Serefe"),
                   size = 1)
    
    history <- get_history(filename)
    last <- history[nrow(history), "Person"]
    if (any(last %in% persons)) {
      paste(last, ", ", text, "!", sep = "")
    } else ""
  })

  output$history <- reactiveTable(function(){
    something_happened()
    history <- get_history(filename)
    if(nrow(history) > 0) {
      history
    } else  {
      NULL
    }
  })
  
  ## TIMELINE ##################################################################
  output$timeline <- reactivePlot(function(){
    something_happened()
    plot_history(filename)
  })

  ## LEADERBOARD ###############################################################
  output$leaderboard <- reactivePlot(function(){
    something_happened()
    plot_leaderboard(filename)
  })

  
  ## DEBUG OUTPUT ##############################################################
  output$debug_timeline <- reactiveTable(function(){
    something_happened()
    history_to_timeline(get_history(filename))
  })

  output$debug_time <- reactiveText(function(){
    something_happened()
    history <- get_history(filename)
    str(history)
  })

  
})
