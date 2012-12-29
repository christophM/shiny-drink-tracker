

get_history <- function(filename, only_last = FALSE){
  history_var<- load(filename)
  history <- get(history_var)
  history$Time <- as.numeric(history$Time)
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
  p <- ggplot(timeline, aes(x = Time, y = count, group = Person, colour = Person)) +
    geom_path() +
      scale_x_continuous(limits = c(0, max(1, max(history$Time) * 1.2, na.rm = TRUE)))
  print(direct.label(p, list("last.bumpup", cex = 1.6)))
}

## Function which plots the barplot (leaderboard)
plot_leaderboard <- function(filename){
  history <- get_history(filename)
  
  ## turn history into count data
  history_tab <- data.frame(sort(table(history$Person), decreasing = TRUE))
  colnames(history_tab) <- "count"
  ## order counts, highest count should be on top
  history_tab$Person <- factor(x = nrow(history_tab):1, labels = rownames(history_tab)[nrow(history_tab):1])
  history_tab
  ## build graphic and print it
  p <- ggplot(history_tab) +
    geom_bar(aes(x = Person, y = count, fill = count), stat = "identity") +
      scale_y_continuous(name = "Drinks counter") +
        scale_x_discrete(name = "") + 
          theme(axis.text = element_text(size = 14)) + 
            coord_flip() 
   print(p)
}

## converts the history file to the data.frame needed to plot the timeline
history_to_timeline <- function(history){
  history$Time <- as.numeric(history$Time)
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
  ## delete last entry, because duplicated entries causes duplicated direct labels
  history <- history[-which(history$Time == max(history$Time)),  ]
  timeline <- rbind(history, end_history)
  timeline
}

