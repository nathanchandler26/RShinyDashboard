################################################################################
# define the server function

server <- function(input, output, session) {
  ##Display text after pressing the search button inside competition tab. sleep is currently being used for
  ##dramatic effect and to show the loading thingy ~dyllan
  observeEvent(input$cpc_button, {
    output$output_text <- renderText({
      Sys.sleep(5)
      print(paste0("CPC ", input$cpc_input, " has been selected"))
    })
  })
  #reactive value for cpc
  cpc <- reactiveValues(cpc_data = data.frame() )
  
  observeEvent(input$load_all_data, {
    output$loading_start <- renderPlot({
      withProgress({
        setProgress(10 / 100, message = "Loading Patent Data...")
        patent <- read_feather('data/g_patent_2012_2021.feather')
        setProgress(40 / 100, message = "Loading Assignee Data...")
        assignee <- read_feather('data/g_assignee_disambiguated_2012_2021.feather')
        setProgress(60 / 100, message = "Loading Location Data...")
        location <- read_feather('data/g_location_disambiguated_2012_2021.feather')
        setProgress(80 / 100, message = "Loading CPC...")
        cpc_data <- fread('data/g_cpc_current_2012_2021.csv')
        print("Data loaded")
        cpc_data$patent_id <- as.character(cpc_data$patent_id)
        print("Filter done")
        cpc$cpc_data <- cpc_data
        
        setProgress(100 / 100, message = "Done...")
        output$data_status <- renderText({
          print(paste("Data loaded"))
        })
      })
    })
  })
  
  
  output$competition_table <- renderTable({
    competition$dt
  })
  
  # Define reactive values
  competition <- reactiveValues(dt = data.frame(), plot = plotly_empty())
  
  observeEvent(input$generate_competitive_positioning, {
    # Filter the cpc codes
    req(cpc$cpc_data())
    dt <- cpc %>% filter(grepl(pattern = paste(input$market_cpcs_input, sep = '', collapse = '|'), x = cpc$cpc_group,ignore.case = T))
    dt <- merge(dt, patent, by = 'patent_id')
    dt <- merge(dt, assignee, by = 'patent_id')
  
    # Get top 10 companies
    totals <- dt %>% filter(disambig_assignee_organization!='') %>% group_by(disambig_assignee_organization) %>% summarize(total=uniqueN(patent_id))
    totals <- totals[order(totals$total,decreasing = T),] %>% slice(1:10)

    # Calculate 5 year CAGR for top 10 companies
    cagr <- data.frame(expand.grid(year=2017:2021,disambig_assignee_organization=totals$disambig_assignee_organization))

    temp <- dt %>%
      filter(disambig_assignee_organization %in% totals$disambig_assignee_organization) %>%
      group_by(year=year(patent_date),disambig_assignee_organization) %>%
      summarise(n=uniqueN(patent_id))
    cagr <- merge(cagr,temp,by = c('year','disambig_assignee_organization'),all.x = T)
    rm(temp)
    cagr[is.na(cagr)] <- 0
    cagr <- cagr %>%
      group_by(disambig_assignee_organization) %>%
      mutate(cum_cnt = cumsum(n)) %>%  # make sure your date are sorted correctly before calculating the cumulative :)
      filter(year %in% c(2017,2021)) %>%
      pivot_wider(id_cols = disambig_assignee_organization,names_from = year,values_from = cum_cnt)
    cagr$cagr_2017_2021 <- round(((cagr$`2021`/cagr$`2017`)^(1/5))-1,3)


    # Calculate avg claim count for top 10 companies
    claims <- dt %>%
      filter(disambig_assignee_organization %in% totals$disambig_assignee_organization) %>%
      select(disambig_assignee_organization,patent_id,num_claims) %>%
      unique() %>%
      group_by(disambig_assignee_organization) %>%
      summarise(avg_claims=round(mean(num_claims)))

    # Combine and save file
    totals <- merge(totals,cagr,by = 'disambig_assignee_organization')
    totals <- merge(totals,claims,by = 'disambig_assignee_organization')
    totals <- totals %>% select(-`2017`,-`2021`) %>% arrange(desc(total))
    
    competition$dt <- totals
    print("rendering competition table")
    output$competition_table <- renderDataTable({competition$dt})
  })
  
  
  # This works for just the top 10 companies
  # output$competition_table <- renderTable({
  #   competition$dt
  # })
  # 
  # competition <- reactiveValues(dt = NULL)
  # 
  # 
  # observeEvent(input$generate_competitive_positioning, {
  #   req(input$market_cpcs_input)
  #   
  #   # Filter the cpc codes
  #   dt <- cpc %>% filter(grepl(pattern = paste(input$market_cpcs_input, sep = '', collapse = '|'), x = cpc$cpc_group,ignore.case = T)) 
  #   dt <- merge(dt, patent, by = 'patent_id')
  #   dt <- merge(dt, assignee, by = 'patent_id') 
  #   dt <- dt %>% filter(disambig_assignee_organization!='') %>% group_by(disambig_assignee_organization) %>% summarize(total=uniqueN(patent_id))
  #   dt <- dt[order(dt$total,decreasing = T),] 
  #   
  #   competition$dt <- head(dt, 10)
  #   
  #   # Enable the button again
  #   updateActionButton(session, inputId = 'generate_competitive_positioning', label = HTML('Generate Top 10 Table'), icon = icon('gear'))
  #   
  #   print("rendering competition table")
  #   output$competition_table <- renderDataTable({competition$dt})
  # })
  
  state_data <- reactive({
    req(input$market_cpcs_input)
    req(cpc$cpc_data())
    # Filter the cpc codes
    dt <- cpc %>% filter(grepl(pattern = paste(input$market_cpcs_input, sep = '', collapse = '|'), x = cpc$cpc_group,ignore.case = T)) %>% select(patent_id) %>% unique()
    dt <- merge(dt, patent, by = 'patent_id')
    dt <- merge(dt, assignee, by = 'patent_id') 
    dt <- merge(dt,location,by = 'location_id')
    
    # tidy up the location data
    dt$state_fips <- str_pad(string = dt$state_fips,width = 2,side = 'left',pad = '0')
    dt$county_fips <- str_pad(string = dt$county_fips,width = 3,side = 'left',pad = '0')
    dt$fips <- paste(dt$state_fips,dt$county_fips,sep = '')
    
    # Summarize data by state
    dt_state <- dt %>% group_by(disambig_state,state_fips) %>% summarise(n=uniqueN(patent_id))
    
    return(dt_state)
  })
  
  observeEvent(input$number_per_state, {
    fig <- plot_geo(state_data(), locationmode = 'USA-states')
    fig <- fig %>% add_trace(
      z = ~n, 
      text = ~disambig_state, 
      locations = ~disambig_state,
      color = ~n, 
      colors = 'Blues'
    )
    fig <- fig %>% colorbar(title = "Count of patents")
    fig <- fig %>% layout(
      title = 'Patents granted by State',
      geo = g
    )
    
    print("rendering states plot")
    output$state_chart_plot <- renderPlotly(fig)
  })
  
  
  
  
  
  
  
  
  
  
  
  # observeEvent(input$number_per_state, {
  #   req(input$market_cpcs_input)
  #   
  #   # Filter the cpc codes
  #   dt <- cpc %>% filter(grepl(pattern = paste(input$market_cpcs_input, sep = '', collapse = '|'), x = cpc$cpc_group,ignore.case = T)) %>% select(patent_id) %>% unique()
  #   dt <- merge(dt, patent, by = 'patent_id')
  #   dt <- merge(dt, assignee, by = 'patent_id') 
  #   dt <- merge(dt,location,by = 'location_id')
  #   
  #   # tidy up the location data
  #   dt$state_fips <- str_pad(string = dt$state_fips,width = 2,side = 'left',pad = '0')
  #   dt$county_fips <- str_pad(string = dt$county_fips,width = 3,side = 'left',pad = '0')
  #   dt$fips <- paste(dt$state_fips,dt$county_fips,sep = '')
  # 
  #   # Summarize data by state
  #   dt_state <- dt %>% group_by(disambig_state,state_fips) %>% summarise(n=uniqueN(patent_id))
  #   
  #   l <- list(color = toRGB("white"), width = 2)
  #   g <- list(
  #     scope = 'usa',
  #     projection = list(type = 'albers usa'),
  #     showlakes = TRUE,
  #     lakecolor = toRGB('white')
  #   )
  #   fig <- plot_geo(dt_state, locationmode = 'USA-states')
  #   fig <- fig %>% add_trace(
  #     z = ~n, 
  #     text = ~disambig_state, 
  #     locations = ~disambig_state,
  #     color = ~n, 
  #     colors = 'Blues'
  #   )
  #   fig <- fig %>% colorbar(title = "Count of patents")
  #   fig <- fig %>% layout(
  #     title = 'Patents granted by State',
  #     geo = g
  #   )
  #   
  #   print("rendering state plot")
  #   output$state_chart_plot <- renderPlotly(fig)
  # })
}

#%>% select(-assignee_type, -location_id, -wipo_kind, -assignee_id, -disambig_assignee_individual_name_last, -disambig_assignee_individual_name_first, -cpc_sequence, -cpc_section, -cpc_class, -cpc_subclass, -cpc_type, -cpc_symbol_position, -patent_abstract, -withdrawn, -filename, -assignee_sequence)
