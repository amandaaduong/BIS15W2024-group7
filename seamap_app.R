library(tidyverse)
library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(readr)

seamap <- read_csv("data/obis_seamap_swot_65e0e9344b011_20240229_153235_site_locations_csv.csv")

ui <- dashboardPage(
  dashboardHeader(title = "Sea Turtle Biogeography - Nesting Sites", titleWidth = 400),
  dashboardSidebar(
    selectInput("country", "Select Country:", choices = unique(seamap$country), selected = "Australia")
  ),
  dashboardBody(
    leafletOutput("map", width = "100%", height = "600px")
  )
)

server <- function(input, output) {
  filtered_data <- reactive({
    filter(seamap, country == input$country)
  })
  
  output$map <- renderLeaflet({
    center_lat <- mean(filtered_data()$latitude)
    center_lon <- mean(filtered_data()$longitude)
    
    leaflet() %>%
      addTiles(urlTemplate = "https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}{r}.png",
               attribution = '&copy; <a href="https://stadiamaps.com/">Stadia Maps</a> contributors') %>%
      setView(lng = center_lon, lat = center_lat, zoom = 4) %>%
      addMarkers(data = filtered_data(),
                 lng = ~longitude, lat = ~latitude,
                 popup = ~paste("Species (Common Name): ", common_name, "<br>",
                                "Site Name: ", site_name, "<br>",
                                "Nesting Status : ", nesting_status, "<br>",
                                "Year(s) Monitored: ", years_monitored))
  })
}

shinyApp(ui, server)
