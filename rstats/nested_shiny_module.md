# Mastering Shiny Module Namespacing: A Complete Guide

Shiny modules are a powerful way to build modular, reusable applications. But once you start adding multiple modules to your app, things can get **tricky** - especially when it comes to **namespacing**.

In this guide, we'll explore:
- When and why to use `NS()` in `_ui` modules.
- How to apply `ns()` when referencing inputs/outputs.
- When to use `ns <- session$ns` in `_server` modules.
- Real-world examples to help you troubleshoot like a pro!

---

## **1. What is Namespacing in Shiny Modules?**

When you create multiple instances of a Shiny module, each instance generates its own set of inputs and outputs. Without namespacing, these elements could **collide** and interfere with one another.

To prevent this, Shiny automatically applies a **namespace** to all inputs/outputs associated with a module.

---

## **2. When to Add `ns <- NS(id)` in `_ui` Modules**

**When:**  
Add `ns <- NS(id)` at the **top** of any `_ui` module where you define UI elements.

**Why:**  
- `NS()` creates a namespace for all input/output IDs.
- Without it, module IDs can clash when multiple modules are loaded.

---

### **Example:**

```r
mod_plotdata_ui <- function(id) {
  ns <- NS(id)  # Namespace applied
  
  tagList(
    selectInput(ns("variable"), "Select a variable:", choices = names(iris)[1:4]),
    plotOutput(ns("plot"))
  )
}
```

## **3. When to Add ns("some_name") in _ui Modules**  


When:
Use ns("some_name") when assigning IDs to inputs and outputs in a namespaced UI module.

Why:

    ns() prefixes the ID with the module's namespace.

    Without ns(), you risk ID collisions.

Example:
```r
selectInput(ns("variable"), "Select a variable:", choices = names(iris)[1:4])
# Correct

selectInput("variable", "Select a variable:", choices = names(iris)[1:4])
# Incorrect! Will cause clashes if multiple modules are loaded.
```

## **4. When to Add ns <- session$ns in _server Modules**

When:
Add `ns <- session$ns` inside a _server module only if you need to refer to a namespaced ID inside a server function.

Why:

    session$ns converts un-namespaced IDs into namespaced ones.

    This is critical when dynamically generating UI with renderUI() or insertUI().

Example:
```r
mod_plotdata_server <- function(id, my_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns  # Needed here for dynamic UI
    
    output$plot_ui <- renderUI({
      plotOutput(ns("hist_plot"))  # Dynamically namespaced
    })
  })
}
```
## **5. Why Does mod_generate_data_server() Not Use ns()?**

Reason:

    mod_generate_data_server() only returns a reactive value (data <- reactiveVal()).

    It doesn't dynamically modify UI elements, so there's no need for ns().

Example:
```r
mod_generate_data_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- reactiveVal()
    
    observeEvent(input$generate_btn, {
      n_rows <- input$n_rows
      data(head(iris, n_rows))  # No need for ns()
    })
    
    return(data)
  })
}
```
## **6. Why Does mod_outer_server() Use ns <- session$ns?**

Reason:

    mod_outer_server() dynamically generates multiple instances of mod_plotdata_server when n_plots changes.

    Since it dynamically creates UI elements, ns() is required.

Example:
```r
mod_outer_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns  # Needed here for dynamic UI
    
    observeEvent(input$n_plots, {
      output$plots_ui <- renderUI({
        plot_ui_list <- lapply(seq_len(input$n_plots), function(i) {
          mod_plotdata_ui(ns(paste0("plot_", i)))  # Dynamically generated IDs
        })
        do.call(tagList, plot_ui_list)
      })
    })
  })
}
```

## **7. Why Does mod_plotdata_server() Use ns <- session$ns?**

Reason:

    mod_plotdata_server() uses renderUI() to dynamically switch between plotOutput() and plotlyOutput().

    Dynamically generated UI elements require explicit namespacing.

Example:
```r

mod_plotdata_server <- function(id, my_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns  # Needed for dynamic plotOutput/plotlyOutput
    
    output$plot_ui <- renderUI({
      plot_type <- input$plot_type
      
      if (plot_type == "ggplot") {
        plotOutput(ns("hist_plot"))  # Dynamically namespaced
      } else {
        plotlyOutput(ns("hist_plot"))
      }
    })
  })
}
```  

## **8. Why Doesn't output$hist_plot Use ns() in mod_plotdata_server()?**

Reason:

    When you define output$hist_plot <- renderPlot(...) inside moduleServer(), output$ automatically uses the module's namespace.

    ns() is only needed in renderUI() or insertUI() where you're dynamically creating elements.

Key Concept:

    output$hist_plot is automatically namespaced when defined within moduleServer().

    But if you're dynamically generating UI, you need to explicitly use ns().

## **9. Quick Recap:**  

| Task	| Do You Need ns()?	| Why? |   
| ------|-------------------|------|  
| mod_generate_data_server| 	No	|Only returns a reactive value, no UI elements|   
| mod_outer_server |  Yes  | (ns <- session$ns) for renderUI()	Dynamically generates multiple modules/plots| 
| mod_plotdata_server	| Yes | (ns <- session$ns) for dynamic UI	Switches between ggplot and plotly dynamically| 
|output$hist_plot | 	No | (output$ automatically applies namespacing)	Namespacing is automatic within moduleServer() | 

## **10. Pro Tip:**

    If your UI has fixed elements, you often don't need session$ns.

    But if you're dynamically generating UI (with renderUI() or insertUI()), you'll need ns() in the server.

You're Now a Shiny Namespacing Guru!

With this knowledge in your toolkit, you're ready to build advanced Shiny apps that scale beautifully without namespace clashes. 

If you have any questions or encounter weird bugs, feel free to ask. Happy coding! 


Here's the full app:   
```r

library(shiny)

library(ggplot2)

library(plotly)

library(bslib)

# ---- mod_generate_data ----

mod_generate_data_ui <- function(id) {

  ns <- NS(id)

  tagList(

    numericInput(ns("n_rows"), "Number of rows to select:", 

                 value = 10, min = 1, max = nrow(iris)),

    actionButton(ns("generate_btn"), "Generate Data")

  )

}

mod_generate_data_server <- function(id) {

  moduleServer(id, function(input, output, session) {

    data <- reactiveVal()

    

    observeEvent(input$generate_btn, {

      n_rows <- input$n_rows

      data(head(iris, n_rows))  # Subset iris based on n_rows

    })

    

    return(data)

  })

}

# ---- mod_plotdata ----

mod_plotdata_ui <- function(id) {

  ns <- NS(id)

  tagList(

    selectInput(ns("variable"), "Select a variable:", 

                choices = names(iris)[1:4]),

    radioButtons(ns("plot_type"), "Plot Type:", 

                 choices = c("ggplot" = "ggplot", "plotly" = "plotly"),

                 inline = TRUE),

    uiOutput(ns("plot_ui"))  # Dynamically generate plot

  )

}

mod_plotdata_server <- function(id, my_data) {

  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    

    # Dynamically generate plot (ggplot or plotly)

    output$plot_ui <- renderUI({

      req(my_data())

      plot_type <- input$plot_type

      

      if (plot_type == "ggplot") {

        plotOutput(ns("hist_plot"))

      } else {

        plotlyOutput(ns("hist_plot"))

      }

    })

    

    # Render the selected plot

    observe({

      req(my_data(), input$variable, input$plot_type)

      var_name <- input$variable

      plot_type <- input$plot_type

      

      if (plot_type == "ggplot") {

        output$hist_plot <- renderPlot({

          req(var_name)

          ggplot(my_data(), aes(.data[[var_name]])) +  # <-- FIXED HERE!

            geom_histogram(binwidth = 0.5, fill = "skyblue", color = "black") +

            labs(title = paste("Histogram of", var_name), x = var_name)

        })

      } else {

        output$hist_plot <- renderPlotly({

          req(var_name)

          p <- ggplot(my_data(), aes(.data[[var_name]])) +  # <-- FIXED HERE!

            geom_histogram(binwidth = 0.5, fill = "skyblue", color = "black") +

            labs(title = paste("Histogram of", var_name), x = var_name)

          ggplotly(p)

        })

      }

    })

  })

}

# ---- mod_outer ----

mod_outer_ui <- function(id) {

  ns <- NS(id)

  

  nav_panel(

    title = paste("Panel:", id),

    sidebarLayout(

      sidebarPanel(

        mod_generate_data_ui(ns("generate_data")),

        numericInput(ns("n_plots"), "Number of plots:", 

                     value = 1, min = 1, max = 4)

      ),

      mainPanel(

        uiOutput(ns("plots_ui"))  # Dynamically generated plots

      )

    )

  )

}

mod_outer_server <- function(id) {

  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    

    # Generate data and pass it to plotdata

    my_data <- mod_generate_data_server("generate_data")

    

    # Dynamically generate multiple mod_plotdata instances

    observeEvent(input$n_plots, {

      output$plots_ui <- renderUI({

        req(my_data())

        n_plots <- input$n_plots

        

        plot_ui_list <- lapply(seq_len(n_plots), function(i) {

          mod_plotdata_ui(ns(paste0("plot_", i)))

        })

        

        do.call(tagList, plot_ui_list)

      })

      

      # Remove previously created instances to avoid duplicates

      isolate({

        lapply(seq_len(input$n_plots), function(i) {

          mod_plotdata_server(paste0("plot_", i), my_data)

        })

      })

    }, ignoreInit = FALSE)

  })

}

# ---- Main App ----

my_demo <- function() {

  ui <- page_navbar(

    title = "My Shiny Demo",

    mod_outer_ui("outer1"),

    mod_outer_ui("outer2")

  )

  

  server <- function(input, output, session) {

    mod_outer_server("outer1")

    mod_outer_server("outer2")

  }

  

  shinyApp(ui, server)

}

# Run the app

my_demo()
```
