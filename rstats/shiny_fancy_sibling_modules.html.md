---
title: "shiny - fancy sibling modules"
author: Simon Coulombe
date: 2025-02-17
categories: [r, shiny]
lang: fr
---


```
library(shiny)
library(ggplot2)
library(bslib)

# Module 1: Go Button
mod_go_button_ui <- function(id) {
  ns <- NS(id)
  actionButton(ns("go"), "Generate Data", class = "btn-primary")
}

mod_go_button_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    return(reactive(input$go))
  })
}

# Module 2: Species Selection
mod_selectspecies_ui <- function(id) {
  ns <- NS(id)
  selectInput(ns("species"), "Select species:",
              choices = unique(iris$Species),
              selected = "setosa")
}

mod_selectspecies_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    return(reactive(input$species))
  })
}

# Module 3: Data Preparation
mod_preparedata_server <- function(id, selected_species, go_trigger) {
  moduleServer(id, function(input, output, session) {
    eventReactive(go_trigger(), {
      req(selected_species())
      df <- subset(iris, Species == selected_species())
      return(df)
    })
  })
}

# Module 4: Y-Variable Selection
mod_select_yvar_ui <- function(id, label = "Select Y Variable:") {
  ns <- NS(id)
  selectInput(ns("y_var"), label,
              choices = c("Sepal.Width", "Petal.Length", "Petal.Width"),
              selected = "Sepal.Width")
}

mod_select_yvar_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    return(reactive(input$y_var))
  })
}

# Module 5: Data Plotting
mod_plotdata_ui <- function(id) {
  ns <- NS(id)
  plotOutput(ns("plot"))
}

mod_plotdata_server <- function(id, prepared_data, y_var) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      df <- prepared_data()
      req(nrow(df) > 0, y_var())

      ggplot(df, aes(x = Sepal.Length, y = .data[[y_var()]])) +
        geom_point(size = 3, color = "steelblue") +
        labs(title = paste("Iris Species:", unique(df$Species)),
             y = y_var(), x = "Sepal.Length") +
        theme_minimal()
    })
  })
}

# Module 6: Data Table
mod_tabledata_ui <- function(id) {
  ns <- NS(id)
  tableOutput(ns("table"))
}

mod_tabledata_server <- function(id, prepared_data, y_var) {
  moduleServer(id, function(input, output, session) {
    output$table <- renderTable({
      df <- prepared_data()
      req(nrow(df) > 0, y_var())
      df[, c("Sepal.Length", y_var()), drop = FALSE]
    })
  })
}

# Parent Module
mod_outer_ui <- function(id,title = "outer") {
  ns <- NS(id)
  bslib::nav_panel(
    title = title,
    layout_sidebar(
      sidebar = sidebar(
        mod_go_button_ui(ns("go_button")),
        mod_selectspecies_ui(ns("species_select"))
      ),
      navset_tab(
        nav_panel("Plot",
                  mod_select_yvar_ui(ns("y_var_select_plot"), "Select Y Variable for Plot:"),
                  mod_plotdata_ui(ns("species_plot"))
        ),
        nav_panel("Table",
                  mod_select_yvar_ui(ns("y_var_select_table"), "Select Y Variable for Table:"),
                  mod_tabledata_ui(ns("species_table"))
        )
      )

    )
  )
}

mod_outer_server <- function(id) {
  moduleServer(id, function(input, output, session) {21w21
    go_trigger <- mod_go_button_server("go_button")
    selected_species <- mod_selectspecies_server("species_select")
    prepared_data <- mod_preparedata_server("prepare_data", selected_species, go_trigger)

    y_var_plot <- mod_select_yvar_server("y_var_select_plot")
    mod_plotdata_server("species_plot", prepared_data, y_var_plot)

    y_var_table <- mod_select_yvar_server("y_var_select_table")
    mod_tabledata_server("species_table", prepared_data, y_var_table)
  })
}

# Main App

ui <-  page_navbar(
  title = "prout",
  mod_outer_ui("outer1", title = "outer1"),
  mod_outer_ui("outer2", title = "outer2")
)

server <- function(input, output, session) {
  mod_outer_server("outer1")
  mod_outer_server("outer2")
}

shinyApp(ui, server)

```