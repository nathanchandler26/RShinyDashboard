library(shiny)
library(shinydashboard)
#install.packages('fresh')
library(fresh)

# This creates a web page -- organized into rows and columns 
# There are 12 parts in each row

load("data/unique_cpc_group.Rdata")
choices <- unique_cpc_group


# Create the theme
mytheme <- create_theme(
  adminlte_color(
    light_blue = "#434C5E"
  ),
  adminlte_sidebar(
    width = "250px",
    dark_bg = "#537593",
    dark_hover_bg = "#81A1C1",
    dark_color = "#2E3440"
  ),
  adminlte_global(
    content_bg = "#FFF",
    box_bg = "#D8DEE9", 
    info_box_bg = "#D8DEE9"
  )
)



ui <- dashboardPage(

  # header
      dashboardHeader(title = 'Patent Analytics'),

  # sidebar
      dashboardSidebar(
        sidebarMenu(
          menuItem(text = 'Home',tabName = 'home'),
          menuItem(text = 'Analysis',tabName = 'analysis',
                   menuSubItem('Competition',tabName = 'competition'),
                   menuSubItem('Trends',tabName = 'trends')
                   )
        )

      ),
  # body
      dashboardBody(
        use_theme(mytheme),
          

        tabItems(
          tabItem(tabName = 'home',
                  title = 'Welcome to the Patent Analytics dashboard!',
                  wellPanel(
                    p('Please wait as the dataset loads', id = 'waiting_text'),
                    withSpinner(
                      uiOutput("load_dataset")
                    )
                  )

          ),
          tabItem(tabName = 'competition',
                  HTML('<p style="font-size:18pt; color:black;">Competition Stuff Goes Here</p>'),
                  tabsetPanel(
                    tabPanel(title = 'Inputs',
                             wellPanel(
                               p('Inputs'),
                               selectInput(inputId = 'cpc_input',
                                           label = 'Please select CPC code:',
                                           choices = choices,#c('Option 1','Option 2','Option 3'),
                                           multiple = T,
                                           width = '200px'),
                               actionButton(inputId = 'cpc_button',label = 'Search',icon = icon('search')
                               )
                             )),
                    
                    tabPanel(title = 'Outputs',
                             wellPanel(
                               withSpinner(
                                 textOutput(outputId = 'output_text')
                               )
                             ))
                  )
          ),
          tabItem(tabName = 'trends',
                  HTML('<p style="font-size:18pt; color:black;">Trend stuff goes here</p>'),
                  tabsetPanel(
                    tabPanel(title = 'Inputs',
                             wellPanel(
                               textInput(inputId = 'my_input', label = 'Input', width = '200px', placeholder = 'Enter text here'),
                               actionButton(inputId = 'button1',label = 'Github',icon = icon('github')),
                             )),
                    
                    tabPanel(title = 'Outputs',
                             wellPanel(
                               plotlyOutput(outputId = 'my_output')
                             ))
                  )
          )
        )

      )


)





