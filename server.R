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


## time when game was started
started_game_at <- as.numeric(Sys.time())

# Define server logic
shinyServer(function(input, output) {

  options(warn = 2)
  ## function which updates everything
  update <- function(){
    input$again
    person <- input$person
    drink <- random_drink()
    history <- update_history(person, drink)
  }

  ## data set is updated for every change of person or by hitting "Drink again"
  observe(update)

  ## choose random drink
  random_drink <- function(){
    drink <- sample(drinks, size = 1)
    return(drink)
  }


  update_history <- function(person, drink){
    drinks_history <- read.csv(filename, stringsAsFactors = FALSE, header = TRUE)
    time_passed <- Sys.time() - started_game_at
    new_drinks <-  c(person, drink, time_passed)
    drinks_history <- rbind(drinks_history, new_drinks)
    colnames(drinks_history) <- c("Person", "Drink", "Time")
    write.csv(drinks_history, file = filename, row.names = FALSE)
  }
  

  
  get_history <- function(only_last = FALSE){
      history <- read.csv(filename, header = TRUE, stringsAsFactors = FALSE)
       if (only_last) {
         return(history[nrow(history), ])
       } else {
         return(history)
       }
   }

  plot_history <- function(){
    history <- get_history()
    timeline <- history_to_timeline(history)
    ## build the graphic
    p <- ggplot(timeline) + geom_line(aes(x = Time, y = count, group = Person, colour = Person))
    print(p)
  }

  ## converts the history file to the data.frame needed to plot the timeline
  history_to_timeline <- function(history){
    ## add count data to data.frame
    history <- ddply(history, .(Person), function(x) {x$count <- 1:nrow(x); x})
    ## add starting point for everyone
    history <- rbind(data.frame(Person = persons,
                                Drink = rep(NA, times = length(persons)),
                                Time = rep(0, times = length(persons)),
                                count = rep(0, times = length(persons))
                                ), history)
    ## add end point of counts for everyone
    end_history <- ddply(history, .(Person), function(x) data.frame(count = max(x$count)))
    end_history$Time <- max(history$Time, na.rm = TRUE)
    end_history$Drink <- NA
    timeline <- rbind(history, end_history)
    timeline
  }
  
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
