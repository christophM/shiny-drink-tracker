################################################################################
##
## User Interface of the game
##
################################################################################

## library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Random"),

  sidebarPanel(
    selectInput("person", "Person die grad dran ist", choices = persons),
    br(),
    actionButton("again", "Muss nochmal")
    ),

  mainPanel(h3(textOutput("text")) ,
            tabsetPanel(
              tabPanel("Raw", tableOutput("history")),
              tabPanel("History", plotOutput("timeline")),
              tabPanel("Debug",
                       tableOutput("debug_timeline"),
                       textOutput("debug_time"))
              )
            )
))
