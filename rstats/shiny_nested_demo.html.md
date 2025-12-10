---
title: "shiny nested modules, use _demo functions"
author: Simon Coulombe
date: 2024-12-16
categories: [r, dbplyr]
lang: fr
---







A month ago I stumbled on this [blogpost](https://emilyriederer.netlify.app/post/shiny-modules/)  by Emiliy Riederer that changed the way I develop my shiny modules and I wanted to spread the good news.
 
Short version, for each module, I also create a _demo() function that generates a tiny shiny app with just the module in it and whatever fake data it needs.  Fastest way to develop/debug a shiny app without launching to full thing to check if something worked.  I leave the _demo() function code in the .R and  I  just comment out the call  to the "_demo()"  function.
 
I dont know if this might be common practice and I'm just years late, but it definitely should be.  
 
Full example from my code, this "visitor log" module : https://bitbucket.cooperators.ca/projects/AI/repos/granulargrowth/browse/R/mod_VisitorsPanel.R
It generates a "panel" with a plot and a table.  So there are three modules (generate plot, generate table, combine both in a panel), eachs with their own _demo function
 
 
There's also [this video from 2023](https://www.youtube.com/watch?v=F6I_jXPWFBk&t=141s) if you are so inclined.

```
mod_VisitorsPanel_ui <- function(id, title = "Visitor Log", width = 1/2) {
  ns <- shiny::NS(id)
  bslib::nav_panel(
    #  logpanel -----
    title = title,
    bslib::layout_column_wrap(
      width = width,
      heights_equal = "row",
      bslib::card(bslib::card_header("Daily Visits"), mod_outputVisitorsPlot_ui(ns("visitors_plot")) , full_screen = TRUE),
      bslib::card(bslib::card_header("Visitors"),     mod_outputVisitorsTable_ui(ns("visitors_table")), full_screen = TRUE)
    )

  )
}

mod_VisitorsPanel_server <- function(id, df_log) {
  moduleServer( id, function(input, output, session){
    mod_outputVisitorsPlot_server("visitors_plot", df_log = df_log)
    mod_outputVisitorsTable_server("visitors_table", df_log = df_log)
  })
}

#' mod_VisitorPanel_demo Functions
#'
#' @noRd
mod_VisitorsPanel_demo <- function(){
  df_log <- dplyr::tibble(
    user = c("annie", "bob", "curtis"),
    R_CONFIG_ACTIVE = c("test", "prod", "test") ,
    timestamp = Sys.time()
  )
  ui <- bslib::page_navbar(mod_VisitorsPanel_ui("x"))

  server <- function(input, output, session) {
    mod_VisitorsPanel_server("x", df_log = df_log)
  }
  shiny::shinyApp(ui, server)
}
# mod_VisitorsPanel_demo()




#' mod_outputVisitorsPlot_ui Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_outputVisitorsPlot_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::plotOutput(ns("visitors_plot"))
  )
}

#' mod_outputVisitorsPlot_server Functions
#'
#' @noRd
mod_outputVisitorsPlot_server <- function(id, df_log){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$visitors_plot <- shiny::renderPlot(
      df_log %>%
        dplyr::mutate(date = as.Date(timestamp)) %>%
        dplyr::count(date, R_CONFIG_ACTIVE) %>%
        ggplot2::ggplot(ggplot2::aes(x = date, y = n, fill = R_CONFIG_ACTIVE)) +
        ggplot2::geom_col() +
        ggplot2::labs(x = "", y = "Visits", title = "Daily number of visits")
    )
  })
}

#' mod_outputVisitorsPlot_demo Functions
#'
#' @noRd
mod_outputVisitorsPlot_demo <- function(){

  df_log <- dplyr::tibble(
    user = c("annie", "bob", "curtis"),
    R_CONFIG_ACTIVE = c("test", "prod", "test") ,
    timestamp = Sys.time()
  )

  ui <- shiny::fluidPage(mod_outputVisitorsPlot_ui("x"))
  server <- function(input, output, session) {
    mod_outputVisitorsPlot_server("x", df_log = df_log)
  }
  shiny::shinyApp(ui, server)
}
# mod_outputVisitorsPlot_demo()


#' mod_outputVisitorsTable_ui Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_outputVisitorsTable_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    DT::dataTableOutput(ns("visitors_table"))
  )
}

#' mod_outputVisitorsTable_server Functions
#'
#' @noRd
mod_outputVisitorsTable_server <- function(id, df_log){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$visitors_table <- DT::renderDataTable({
      DT::datatable(
        df_log %>%
          dplyr::arrange(dplyr::desc(timestamp)), fillContainer = TRUE)
    })
  })
}

#' mod_outputVisitorsTable_demo Functions
#'
#' @noRd
mod_outputVisitorsTable_demo <- function(){

  df_log <- dplyr::tibble(
    user = c("annie", "bob", "curtis"),
    R_CONFIG_ACTIVE = c("test", "prod", "test"),
    timestamp = Sys.time()
  )

  ui <- shiny::fluidPage(mod_outputVisitorsTable_ui("x"))
  server <- function(input, output, session) {
    mod_outputVisitorsTable_server("x", df_log = df_log)
  }
  shiny::shinyApp(ui, server)
}
# mod_outputVisitorsTable_demo()
```