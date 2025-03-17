#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

install.packages("lubridate")
install.packages("forcats")
install.packages("maps")
library(shiny)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(forcats)
library(DT)
library(maps)

### Data Preprocessing
shootings <- read.csv("https://uwmadison.box.com/shared/static/qgwddd64hcjroqqopmudip3csp08hwes.csv")

shootings <- shootings %>% 
  drop_na() %>% 
  filter_all(all_vars(. != "")) %>%
  filter(!(state %in% c("AK", "HI"))) %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d"),
         year = year(date)) %>%
  mutate(armed_category = case_when
         (
           grepl("gun", armed, ignore.case = TRUE) ~ "gun",
           armed %in% c("unarmed") ~ "unarmed",
           TRUE ~ "other arm"
         )
  )

shootings$race <- factor(shootings$race, 
                         levels = c("A", "B", "H", "N", "O", "W"), 
                         labels = c("Asian", "Black", "Hispanic", 
                                    "Native", "Other", "White"))

### Define plotting function
## Define map plot
map_plot <- function(data, selected_points){
  ggplot(data, aes(x = longitude, y = latitude)) +
    geom_point(
      aes(color = race, shape = gender, 
          alpha = as.numeric(selected_points),
          size = as.numeric(selected_points)),
      alpha = 0.7
    ) +
    borders("state", colour = "gray") +
    scale_shape_manual(values = c("M" = 16, "F" = 17)) +
    scale_color_brewer(palette = "Set2") +
    scale_alpha_continuous(range = c(0.5, 1), guide = "none") +
    scale_size_continuous(range = c(1.5, 3), guide = "none") +
    labs(title = "Geographic Distribution of Police Shootings",
         subtitle = "We removed the data of AK and HI. The shapes of points means genders. \n And the colors of points means races.",
         x = "Longitude", y = "Latitude") +
    theme_minimal()
}
## Define bar plot
armed_bar_plot <- function(data) {
  data %>%
    ggplot(aes(x = fct_infreq(race), fill = armed_category)) +
    geom_bar(position = "fill", col = "black") +
    labs(title = "Armed Status Distribution by Race", 
         subtitle = "armed_category means WHAT THE VICTIM WAS ARMED WITH",
         x = "Race", y = "Proportion") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_manual(values = c("#4E79A7", "#A0CBE8", "#F28E2B"))
}

## Define pie chart
race_pie_plot <- function(data) {
  race_counts <- data %>%
    count(race) %>%
    mutate(percentage = n / sum(n))
  
  ggplot(race_counts, aes(x = "", y = n, fill = race)) +
    geom_bar(width = 1, stat = "identity", color = "black") +
    coord_polar("y", start = 0) +
    geom_text(aes(label = scales::percent(percentage)),
              position = position_stack(vjust = 0.5),
              size = 2.5) +
    scale_fill_brewer(palette = "Set2") +
    labs(title = "Case Distribution by Race",
         subtitle = "Proportion of police shooting cases across racial groups",
         fill = "Race") +
    theme_void() +  
    theme(legend.position = "bottom",
          plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5))
}

filtered_table <- function(data) {
  data %>%
    select(id, name, date, city, state, age, gender, race, armed_category,
           flee, signs_of_mental_illness, threat_level, body_camera)
}

### Construct UI
ui <- fluidPage(
  titlePanel("DOES RACISM EXIST IN U.S. POLICE SHOOTINGS?"),
  fluidRow(
    column(4,
           wellPanel(
             selectizeInput(
               "years", "Select Year(s)",
               choices = sort(unique(shootings$year)),
               multiple = TRUE,
               selected = sort(unique(shootings$year)), 
               options = list(
                 placeholder = 'Select years...',
                 plugins = list("remove_button"),
                 maxItems = 8
               )
             ),
             actionButton("reset", "Reset", icon = icon("undo"))
           ),
           plotOutput("pie", height = "300px"),
           plotOutput("bar", height = "300px")
    ),
    column(8,
           div(style = "margin-bottom: 20px; font-size: 1em; color: #666;",
               HTML("<strong>Interactive Guide:</strong><br>
                    The dataset we use contains the detailed information of police shooting cases in the US(not including AK and HI) from 2015 to 2022. These data were collected and published by the Washington Post since 2015. After data preprocessing, the dataset include 5016 incidents in total and 19 columns. <br>
                    This interface can help you check the US shooting information and explore if there exists racism in U.S. Police Shooting during that time.
                    First, Start by selecting one or multiple years using the dropdown menu. 
                    And then you can brush over the scatter map plot to explore details about the selected cases. 
                    This allows you to check the proportion of races and if certain racial groups were more likely to be shot despite not carrying arms. 
                    The reset button will restore the plots of full dataset and clear all filters.")
           ),
           plotOutput("map", 
                      brush = brushOpts(id = "plot_brush", resetOnNew = FALSE),
                      height = "600px")
    )
  ),
  DTOutput("selected_table")
)

### Construct Server
server <- function(input, output, session) {
  base_data <- reactive({
    req(input$years)
    shootings %>% 
      filter(year %in% as.integer(input$years)) 
  })
  
  selected_points <- reactiveVal(rep(TRUE, nrow(shootings)))
  
  observeEvent(input$plot_brush, {
    brush <- input$plot_brush
    df <- brushedPoints(base_data(), brush, allRows = TRUE)
    selected_points(df$selected_)
  })
  
  observeEvent(input$years, {
    selected_points(rep(TRUE, nrow(base_data())))
    session$resetBrush("plot_brush")
  })
  
  final_data <- reactive({
    base_data() %>%
      filter(selected_points()) %>%
      mutate(across(c(state, race), fct_drop))
  })
  
  output$map <- renderPlot({
    map_plot(base_data(), selected_points())
  })
  
  output$bar <- renderPlot({
    armed_bar_plot(final_data())
  })
  
  output$pie <- renderPlot({ 
    race_pie_plot(final_data())
  })
  
  output$selected_table <- renderDT({
    datatable(
      filtered_table(final_data()),
      rownames = FALSE
    )
  })
  
  observeEvent(input$reset, {
    updateSelectizeInput(session, "years", 
                         selected = sort(unique(shootings$year)))
    session$resetBrush("plot_brush")
  })
}

shinyApp(ui, server)