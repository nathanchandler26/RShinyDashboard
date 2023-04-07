################################################################################
# define the server function



function(input, output, session) {
  ##Display text after pressing the search button inside competition tab. sleep is currently being used for
  ##dramatic effect and to show the loading thingy ~dyllan
  observeEvent(input$cpc_button, {
    output$output_text <- renderText({
      Sys.sleep(5)
      print(paste0("CPC ", input$cpc_input, " has been selected"))
    })
  })
  load_dataset <- function(){
    
    term <- fread('~/g_us_term_of_grant_2012_2021.csv')
    patent <- fread('~/g_patent_2012_2021.csv')
    assignee <- fread('~/g_assignee_disambiguated_2012_2021.csv')
    location <- fread('~g_location_disambiguated_2012_2021.csv')
    cpc <- fread('~/g_cpc_current_2012_2021.csv')
    updateTabItems(session, "home", "waiting_text", "Dataset loaded! We're ready for you.")
  }
  
  
  competitive_analysis_result <- function(cpc_code){
    
  }
}
