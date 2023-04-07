################################################################################
# define the server function



server <- function(input,output,session) {

    observeEvent(input$cpc_button, {
      output$output_text <- renderPrint({
        paste0("CPC ", input$cpc_input, " has been selected")
      })
    })
    observeEvent(input$input_button, {
      output$output_text <- renderPrint({
        paste0("Input ", input$input_input, " has been selected")
      })
    })
  
  
  
}
