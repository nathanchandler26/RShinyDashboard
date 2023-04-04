# This creates a web page -- organized into rows and columns 
# There are 12 parts in each row
ui <- fluidPage(
  
  fluidRow(
    h1('Page Title')
  ),
  fluidRow(
    column(width = 6, 
           wellPanel(
            p('Hello world')
            )
    ),
    column(width = 6,
           wellPanel(
             p('Panel 2')
           )
    )
    ),
    tabsetPanel(
      tabPanel(title = 'Inputs',
               wellPanel(
                 textInput(inputId = 'my_input', label = 'Input', width = '200px', placeholder = 'Enter text here')
               )),
      tabPanel(title = 'Outputs',
               wellPanel(
                 plotlyOutput(outputId = 'my_output')
               ))
))

# Hello