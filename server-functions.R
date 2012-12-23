
## function which updates everything
update <- function(){
  input$again
  person <- input$person
  drink <- random_drink()
  history <- update_history(person, drink)
}


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

