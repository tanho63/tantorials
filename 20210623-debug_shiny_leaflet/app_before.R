source("www/global.R")
source("www/mapping_data_manipulation.R")

library(shiny)
library(shinyWidgets)
library(leaflet)

# Define UI 
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
  
  ## Topics depend on the goal selected
  goal_reactive <- reactive({
    merged_df %>% filter(Goal == input$sdg)
  })
  
  observeEvent(goal_reactive(),{
    
    choices <- goal_reactive() %>% mutate(Topic = trimws(Topic)) %>% distinct(Topic)  %>% pull
    updatePickerInput(session, "topic", choices = choices)
  })


 ## Indicators depend on the sdg and topic selected

 topic_reactive <- reactive({
   merged_df %>% filter(Goal == input$sdg & Topic == input$topic)
 })

 observeEvent(topic_reactive(), {
   
   choices <- topic_reactive() %>% mutate(`Indicator Name` = trimws(`Indicator Name`)) %>%  distinct(`Indicator Name`) %>% pull
   updatePickerInput(session, "indicator", choices = choices)
 })

 ## Year slider input
 
 #Update years slicer
 df_reactive <- reactive({
   df <- merged_df %>% 
     filter(`Indicator Name` == input$indicator)
 })
 
 output$year_slider <- renderUI({
   
   # sdg_col <- goal_target_cols %>% filter(Goal_Name == input$sdg) %>% distinct(Goal_col) %>% pull()
   # years <- as.character(sort(year_reactive() %>% distinct(Year) %>% pull()))
   # years <- unique(merged_mapping_df$Year)
   req(input$sdg)
   sdg_col <- "maroon"
   setSliderColor(sdg_col, 1)
   sliderTextInput(
     inputId = "year",
     label = "Select Year",
     grid = TRUE,
     force_edges = TRUE,
     choices = sort(unique(df_reactive()$Year)),
     width = "190%"
   )
 })

 ## Reactive elements that will be used on the table and map
 indicator_reactive <- reactive({
   req(input$sdg)
   merged_mapping_df %>% 
     mutate(Goal  == as.character(Goal)) %>%   
     filter(Goal == input$sdg & Topic == input$topic & `Indicator Name` == input$indicator) %>% 
     select(Goal, Topic, `Indicator Name`, Year, ADM0_NAME, value) %>% 
     arrange(Goal, Topic, `Indicator Name`, Year, ADM0_NAME) 
 })
 
 year_reactive <- reactive({
   req(input$sdg)
   indicator_reactive() %>% 
     dplyr::filter(Year %in% input$year)
 })
 
 ## Table (this is used to show that the filter works well)
 output$tab <- renderDataTable({
   year_reactive() %>% st_drop_geometry()
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

 observe({

   req(input$sdg,input$topic, input$indicator, input$year)

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
