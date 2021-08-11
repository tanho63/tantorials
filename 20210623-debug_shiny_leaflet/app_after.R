source("www/global.R")
source("www/mapping_data_manipulation.R")

library(shiny)
library(shinyWidgets)
library(leaflet)

ui <- fluidPage(title = "Dummy",
                tags$style(type="text/css",
                           ".shiny-output-error { visibility: hidden; }",
                           ".shiny-output-error:before { visibility: hidden; }"
                ),
                fluidRow(
                  br(),
                  column(width = 4,
                         pickerInput(
                           inputId = "sdg",
                           label = span("Select goal", style="color:black;font-size:16px"), 
                           choices = goals_list)),
                  column(width = 4,
                         pickerInput(
                           inputId = "topic",
                           label = span("Select topic", style="color:black;font-size:16px"), 
                           choices = "")),
                  column(width = 4,
                         pickerInput(
                           inputId = "indicator",
                           label = span("Select indicator", style="color:black;font-size:16px"), 
                           choices = ""))
                ),br(), br(),
                fluidRow(
                  column(width = 6,offset = 2,  uiOutput("year_slider"))
                ),br(), br(),
                fluidRow(
                  column(width = 6, dataTableOutput("tab")),
                  column(width = 6, leafletOutput("map", height = 500))
                ))
# Define server logic 
server <- function(input, output, session) {
  observeEvent(input$sdg,{
    choices <- merged_df %>% filter(Goal == input$sdg) %>% 
      mutate(Topic = trimws(Topic)) %>% 
      distinct(Topic) %>% 
      pull()
    # browser()
    updatePickerInput(session, "topic", choices = choices, selected = choices[1])
  })
  ## Indicators depend on the sdg and topic selected
  observeEvent(paste(input$sdg,input$topic), {
    choices <- merged_df %>%
      filter(Goal %in% input$sdg, Topic %in% input$topic) %>% 
      mutate(`Indicator Name` = trimws(`Indicator Name`)) %>%  
      distinct(`Indicator Name`) %>% 
      pull()
    updatePickerInput(session, "indicator", choices = choices, selected = choices[1])
  })
  output$year_slider <- renderUI({
    req(input$sdg)
    req(input$indicator!= "")
    # sdg_col <- "maroon"
    # setSliderColor(sdg_col, 1)
    df_years <- merged_df %>% 
      filter(`Indicator Name` == input$indicator) %>% 
      pull(Year) %>% 
      unique() %>% 
      sort()
    sliderTextInput(
      inputId = "year",
      label = "Select Year",
      grid = TRUE,
      force_edges = TRUE,
      choices = df_years,
      selected = df_years[1],
      width = "190%"
    )
  })
  ## Reactive elements that will be used on the table and map
  year_reactive <- reactive({
    req(input$sdg)
    req(input$topic)
    req(input$indicator)
    req(input$year)
    merged_mapping_df %>% 
      dplyr::filter(as.character(Goal) %in% input$sdg, 
                    Topic %in% input$topic,
                    `Indicator Name` %in% input$indicator,
                    Year %in% input$year
      ) %>% 
      select(Goal, Topic, `Indicator Name`, Year, ADM0_NAME, value) %>% 
      arrange(Goal, Topic, `Indicator Name`, Year, ADM0_NAME) 
  })
  ## Table (this is used to show that the filter works well)
  output$tab <- renderDataTable({
    year_reactive() %>% 
      st_drop_geometry()
  })
  ## Leaflet map
  ## Parts of the leaflet map that are static
  output$map <- renderLeaflet({
    req(input$sdg,input$topic, input$indicator, input$year)
    leaflet(data = merged_mapping_df) %>% 
      addTiles() %>% 
      setView(lng = 20.48554, lat = 6.57549,  zoom = 3)
  })
  ## ********Why is this not working yet the table above clearly shows that the filters work***********
  observeEvent(year_reactive(),{
    # req(input$sdg,input$topic, input$indicator, input$year)
    req(nrow(year_reactive())>0)
    ## Define color palette
    pal <- colorBin(palette = "YlOrRd", domain = year_reactive()$value)
    ## Define the labels
    labels <- sprintf(
      "<strong>%s</strong><br/><strong>%s</strong>%s<br/><strong>%s</strong>%g",
      year_reactive()$ADM0_NAME,"Year: ",year_reactive()$Year,"Value: ",
      year_reactive()$value) %>%
      lapply(htmltools::HTML)
    ## Generate the dynamic part of the map
    leafletProxy('map') %>%
      addPolygons(data = year_reactive(), color = "#397E4A", weight = 1, dashArray = "3", fillColor = ~pal(year_reactive()$value),
                  highlight = highlightOptions(
                    weight = 4,
                    color = "#397E4A",
                    dashArray = "",
                    bringToFront = TRUE),
                  label = labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto"))
  })
  ## ************************************************************************************************ 
}
# Run the application 
shinyApp(ui = ui, server = server)