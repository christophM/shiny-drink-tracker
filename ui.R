################################################################################
##
## User Interface of the game
##
################################################################################

## library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Drink tracker"),

  sidebarPanel(
    selectInput("person", "Choose person", choices = persons),
    br(),
    actionButton("again", "Drink!")
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
