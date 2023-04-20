################################################################################
# define the server function

server <- function(input, output, session) {
  # Competitive Positioning
  
  output$competition_table <- renderTable({
    competition$dt
  })
  
  # Define reactive values
  competition <- reactiveValues(dt = data.frame(), plot = plotly_empty())
  
  observeEvent(input$generate_competitive_positioning, {
    # Filter the cpc codes
    print(coalesce(input$CPC_subgroup, input$market_cpcs_input,input$class_cpcs_input))
    dt <- cpc %>% filter(grepl(pattern = paste(coalesce(input$CPC_subgroup, input$market_cpcs_input,input$class_cpcs_input), sep = '', collapse = '|'), x = cpc$cpc_group,ignore.case = T))
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
  
  
  # States plot
  state_data <- reactive({
      # print("entering state data")
      # print(paste(input$market_cpcs_input_2))
      # req(coalesce(input$CPC_subgroup_2, input$market_cpcs_input_2,input$class_cpcs_input_2))
      # print("after req")

    
    # Filter the cpc codes
    dt <- cpc %>% filter(grepl(pattern = paste(coalesce(input$CPC_subgroup_2, input$market_cpcs_input_2,input$class_cpcs_input_2), sep = '', collapse = '|'), x = cpc$cpc_group,ignore.case = T))
    print("after dt")
    keep <- cpc %>% 
      filter(grepl(pattern = paste(coalesce(input$CPC_subgroup_2, input$market_cpcs_input_2,input$class_cpcs_input_2), sep = '', collapse = '|'), x = cpc$cpc_group,ignore.case = T)) %>% 
      select(patent_id) %>% 
      unique()
    
    dt <- dt %>% filter(patent_id %in% keep$patent_id)
    
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
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      showlakes = TRUE,
      lakecolor = toRGB('white')
    )
    fig <- plot_geo(data = state_data(), locationmode = 'USA-states')
    fig <- fig %>% add_trace(
      z = ~n,
      text = ~disambig_state,
      locations = ~disambig_state,
      color = ~n,
      colors = 'Blues'
    )
    fig <- fig %>% colorbar(title = "Count of Patents")
    fig <- fig %>% layout(
      title = 'Patents Granted by State',
      geo = g
    )
    
    print("rendering states plot")
    output$state_chart_plot <- renderPlotly(fig)
  })
}