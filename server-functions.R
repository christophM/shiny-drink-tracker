

get_history <- function(filename, only_last = FALSE){
  history_var<- load(filename)
  history <- get(history_var)
  if (only_last) {
    return(history[nrow(history), ])
  } else {
    return(history)
  }
}

plot_history <- function(filename){
  history <- get_history(filename)
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
                              Time = rep(0, times = length(persons)),
                              count = rep(0, times = length(persons))
                              ), history)
  ## add end point of counts for everyone
  end_history <- ddply(history, .(Person), function(x) data.frame(count = max(x$count)))
  end_history$Time <- max(history$Time, na.rm = TRUE)
  timeline <- rbind(history, end_history)
  timeline
}

