################################################################################
##
## User Interface of the game
##
################################################################################


## add choose to persons, because when the game starts the first person in the list does not
## automatically drink
persons <- c("[choose person]", persons)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Drink tracker"),

  sidebarPanel(
    selectInput("person", "", choices = persons),
    br(),
    actionButton("again", "Drink again!")
    ),

  mainPanel(h3(textOutput("text")) ,
            tabsetPanel(
              tabPanel("Timeline", plotOutput("timeline")),
              tabPanel("Leaderboard", plotOutput("leaderboard")),
              tabPanel("Raw", tableOutput("history")),
              tabPanel("Debug",
                       tableOutput("debug_timeline"),
                       textOutput("debug_time")
                       )
              )
            )
))
