###############################################################################
##
## Simply start the game application
##
################################################################################
## install.packages("devtools")
## for the action button: 
## devtools::install_github("shiny-incubator", "rstudio")


library("shiny")
library("shinyIncubator")


drinks <- c("Bier", "Vodka", "Rum")
persons <- c("Heidi", "Christoph", "Desiré", "Levent", "Daniel")
runApp("./")


