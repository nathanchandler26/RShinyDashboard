library(shiny)
library(shinydashboard)
#install.packages('fresh')
library(shinycssloaders)
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
          menuItem(text = 'Analyses',tabName = 'analysis',
                   menuSubItem('Competition',tabName = 'competition'),
                   menuSubItem('Top 10 Organizations',tabName = 'top10'),
                   menuSubItem('Number of Patents by State', tabName = 'states')
                   )
        )
      ),
  # body
  dashboardBody(
    use_theme(mytheme),
    
    tabItems(
      tabItem(
        tabName = 'home',
        title = 'Welcome to the Patent Analytics dashboard!',
        wellPanel(
          p('Please wait as the dataset loads', id = 'waiting_text')
        )
      ),
      tabItem(
        tabName = 'competition',
        HTML('<p style="font-size:18pt; color:black;">Competition Stuff Goes Here</p>'),
        tabsetPanel(
          tabPanel(
            title = 'Inputs',
            wellPanel(
              p('Inputs'),
              selectInput(
                inputId = 'cpc_input',
                label = 'Please select CPC code:',
                choices = choices,#c('Option 1','Option 2','Option 3'),
                multiple = T,
                width = '200px'
              ),
              actionButton(
                inputId = 'cpc_button',
                label = 'Search',
                icon = icon('search')
              )
            )
          ),
          
          tabPanel(
            title = 'Outputs',
            wellPanel(
              withSpinner(
                textOutput(outputId = 'output_text')
                #DT::dataTableOutput(outputId = 'competition_table')
              )
            )
          )
        )
      ),
      tabItem(
        tabName = 'top10',
        HTML('<p style="font-size:16pt; color:black;">Competitive Positioning Data for the Top 10 Organizations for the Selected CPC Code(s)</p>'),
        tabsetPanel(
          tabPanel(
            title = 'Select CPC(s)',
            wellPanel(
              selectInput(
                inputId = 'market_cpcs_input',
                label = 'Please select CPC code(s):',
                choices = choices,
                multiple = T,
                width = '200px'
              ),
              actionButton(
                inputId = 'generate_competitive_positioning',
                label = HTML('Generate Top 10 Table'),
                icon = icon('gear')
              )
            )
          ),

          tabPanel(
            title = 'Top 10 Table',
            wellPanel(
              withSpinner(
                DT::dataTableOutput(outputId = 'competition_table')
              )
            )
          )
        )
      ),

      tabItem(
        tabName = 'states',
        HTML('<p style="font-size:16pt; color:black;">Number of Patents Granted by State for the Selected CPC Code(s)</p>'),
        tabsetPanel(
          tabPanel(
            title = 'Select CPC(s)',
            wellPanel(
              selectInput(
                inputId = 'market_cpcs_input',
                label = 'Please select CPC code(s):',
                choices = choices,
                multiple = T,
                width = '200px'
              ),
              actionButton(
                inputId = 'number_per_state',
                label = HTML('Generate State Chart'),
                icon = icon('gear')
              )
            )
          ),
          
          tabPanel(
            title = 'State Chart',
            wellPanel(
              withSpinner(
                plotlyOutput(outputId = 'state_chart_plot')
              )
            )
          )
        )
      )
    )
  )
)