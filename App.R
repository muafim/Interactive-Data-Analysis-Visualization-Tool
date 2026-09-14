library(shiny)
library(shinydashboard)
library(shinythemes)
library(readxl)
library(dplyr)
library(ggplot2)
library(DT)
library(vcd)
library(plotly)
library(tidyr)

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Aplikasi Pengolahan Data Excel", titleWidth = 300),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Upload File", tabName = "file_upload", icon = icon("file-upload")),
      fileInput("file1", "Pilih File Excel", accept = c(".xlsx", ".xls")),
      
      menuItem("Visualisasi Data", tabName = "visualisasi", icon = icon("chart-line")),
      menuItem("Proses Missing Value", tabName = "missing_value", icon = icon("exclamation-triangle")),
      menuItem("Korelasi Variabel Kategorik", tabName = "correlation", icon = icon("link"))
    )
  ),
  
  dashboardBody(
    shinythemes::shinytheme("flatly"),
    
    # Styling for background and other elements
    tags$style(HTML('
      .box { background-color: #f9f9f9; }
      .box-header { background-color: #b0c6cc; }
      .box-primary { border-color: #c1dbe3; }
      .content-wrapper { background-color: #f4f9fc; }
    ')),
    
    tabItems(
      # Tab for uploading file and displaying data
      tabItem(tabName = "file_upload",
              fluidRow(
                box(title = "Tabel Data", width = 12, status = "primary", solidHeader = TRUE, DTOutput("data_table"))
              )
      ),
      
      # Tab for visualizing data
      tabItem(tabName = "visualisasi",
              fluidRow(
                box(title = "Visualisasi Data", width = 12, status = "primary", solidHeader = TRUE, plotlyOutput("data_plot"))
              ),
              fluidRow(
                box(title = "Pilih Visualisasi", width = 6, status = "primary", solidHeader = TRUE,
                    selectInput("plot_type", "Pilih Jenis Visualisasi:", choices = c("Histogram", "Boxplot", "Bar Plot", "Pie Chart")),
                    uiOutput("select_column"),
                    conditionalPanel(
                      condition = "input.plot_type == 'Histogram'",
                      numericInput("binwidth", "Pilih Binwidth:", value = 30, min = 1, max = 100)
                    ),
                    actionButton("process_visualization", "Proses Visualisasi", class = "btn-primary")  # Added Process button
                )
              )
      ),
      
      # Tab for missing value processing
      tabItem(tabName = "missing_value",
              fluidRow(
                box(title = "Jumlah Missing Value per Kolom", width = 12, status = "primary", solidHeader = TRUE, DTOutput("missing_value_table"))
              ),
              fluidRow(
                box(title = "Pilih Metode Pengisian Missing Value", width = 12, status = "primary", solidHeader = TRUE,
                    selectInput("missing_value_method", "Pilih Metode Pengisian:", choices = c("Hapus Baris", "Isi dengan Rata-rata", "Isi dengan Median")),
                    actionButton("process_missing", "Proses Missing Value", class = "btn-primary")
                )
              )
      ),
      
      # Tab for correlation analysis between categorical variables
      tabItem(tabName = "correlation",
              fluidRow(
                box(title = "Pilih Kolom Kategorik untuk Korelasi", width = 12, status = "primary", solidHeader = TRUE,
                    uiOutput("select_categorical_for_correlation"),
                    actionButton("correlationButton", "Tampilkan Korelasi", class = "btn-info")
                )
              ),
              fluidRow(
                box(title = "Tabel Korelasi Kategorik", width = 12, status = "primary", solidHeader = TRUE, DTOutput("correlation_table"))
              )
      )
    )
  )
)

server <- function(input, output, session) {
  
  data <- reactive({
    req(input$file1)
    df <- read_excel(input$file1$datapath, col_types = "guess")
    df <- df %>% mutate(across(where(is.factor), as.character))
    return(df)
  })
  
  # Display the data in the table after upload
  output$data_table <- renderDT({
    req(data())
    datatable(data(), options = list(scrollX = TRUE))
  })
  
  # Missing Value Processing
  output$missing_value_table <- renderDT({
    req(data())
    missing_data <- sapply(data(), function(x) sum(is.na(x)))
    missing_df <- data.frame(Column = names(missing_data), MissingValues = missing_data)
    datatable(missing_df, options = list(scrollX = TRUE))
  })
  
  observeEvent(input$process_missing, {
    req(data())
    
    if (input$missing_value_method == "Hapus Baris") {
      # Remove rows with missing values
      df_processed <- data() %>% drop_na()
    } else if (input$missing_value_method == "Isi dengan Rata-rata") {
      # Fill missing values with the mean (for numeric columns)
      df_processed <- data()
      numeric_cols <- names(df_processed)[sapply(df_processed, is.numeric)]
      for (col in numeric_cols) {
        df_processed[[col]] <- ifelse(is.na(df_processed[[col]]), mean(df_processed[[col]], na.rm = TRUE), df_processed[[col]])
      }
    } else if (input$missing_value_method == "Isi dengan Median") {
      # Fill missing values with the median (for numeric columns)
      df_processed <- data()
      numeric_cols <- names(df_processed)[sapply(df_processed, is.numeric)]
      for (col in numeric_cols) {
        df_processed[[col]] <- ifelse(is.na(df_processed[[col]]), median(df_processed[[col]], na.rm = TRUE), df_processed[[col]])
      }
    }
    
    # Update the data table with the processed data
    output$data_table <- renderDT({
      datatable(df_processed, options = list(scrollX = TRUE))
    })
    
    # Update the data in the reactive data object
    data <<- reactive({ df_processed })
  })
  
  # Select column for correlation analysis
  output$select_categorical_for_correlation <- renderUI({
    req(data())
    categorical_cols <- names(data())[sapply(data(), is.character)]
    
    selectInput("selected_categorical_for_correlation", "Pilih Kolom Kategorik", choices = categorical_cols, multiple = TRUE)
  })
  
  observeEvent(input$correlationButton, {
    req(input$file1)
    
    categorical_cols <- input$selected_categorical_for_correlation
    
    if (length(categorical_cols) > 1) {
      correlation_matrix <- matrix(NA, nrow = length(categorical_cols), ncol = length(categorical_cols))
      rownames(correlation_matrix) <- categorical_cols
      colnames(correlation_matrix) <- categorical_cols
      
      for (i in 1:(length(categorical_cols) - 1)) {
        for (j in (i + 1):length(categorical_cols)) {
          tbl <- table(data()[[categorical_cols[i]]], data()[[categorical_cols[j]]])
          cramer_v <- assocstats(tbl)$cramer
          correlation_matrix[i, j] <- cramer_v
          correlation_matrix[j, i] <- cramer_v
        }
      }
      
      output$correlation_table <- renderDT({
        datatable(correlation_matrix, options = list(scrollX = TRUE))
      })
    } else {
      output$correlation_table <- renderDT({
        datatable(data.frame(Peringatan = "Pilih lebih dari satu kolom kategorik"), options = list(scrollX = TRUE))
      })
    }
  })
  
  # Select column for visualization
  output$select_column <- renderUI({
    req(data())
    all_cols <- names(data())
    
    selectInput("selected_column", "Pilih Kolom untuk Visualisasi", choices = all_cols)
  })
  
  observeEvent(input$process_visualization, {
    req(input$file1)
    
    output$data_plot <- renderPlotly({
      req(input$plot_type)
      
      selected_col <- input$selected_column
      
      if (input$plot_type == "Histogram" && is.numeric(data()[[selected_col]])) {
        bin_width <- input$binwidth
        min_value <- min(data()[[selected_col]], na.rm = TRUE)
        max_value <- max(data()[[selected_col]], na.rm = TRUE)
        
        breaks_seq <- seq(floor(min_value / bin_width) * bin_width, 
                          ceiling(max_value / bin_width) * bin_width, 
                          by = bin_width)
        
        plot_data <- ggplot(data(), aes(x = .data[[selected_col]])) + 
          geom_histogram(binwidth = bin_width, fill = "#6baed6", color = "#c6dbef") +
          scale_x_continuous(breaks = breaks_seq, labels = scales::comma(breaks_seq)) +
          theme_minimal() +
          labs(title = paste("Histogram of", selected_col), x = selected_col, y = "Frequency")
        
        # Convert ggplot to plotly for interactivity
        ggplotly(plot_data) %>%
          layout(hoverlabel = list(bgcolor = "white", font = list(color = "black")))
        
      } else if (input$plot_type == "Boxplot" && is.numeric(data()[[selected_col]])) {
        plot_data <- ggplot(data(), aes(y = .data[[selected_col]])) +
          geom_boxplot(fill = "#e3f2fd", color = "#6baed6") +
          theme_minimal() +
          labs(title = paste("Boxplot of", selected_col), y = selected_col) +
          theme(plot.title = element_text(hjust = 0.5))
        
        # Convert ggplot to plotly for interactivity
        ggplotly(plot_data) %>%
          layout(hoverlabel = list(bgcolor = "white", font = list(color = "black")))
        
      } else if (input$plot_type == "Bar Plot" && is.character(data()[[selected_col]])) {
        plot_data <- ggplot(data(), aes(x = .data[[selected_col]])) +
          geom_bar(fill = "#6baed6", color = "white") +
          theme_minimal() +
          labs(title = paste("Bar Plot of", selected_col), x = selected_col, y = "Count") +
          theme(axis.text.x = element_text(angle = 45, hjust = 1))
        
        # Convert ggplot to plotly for interactivity
        ggplotly(plot_data) %>%
          layout(hoverlabel = list(bgcolor = "white", font = list(color = "black")))
        
      } else if (input$plot_type == "Pie Chart" && is.character(data()[[selected_col]])) {
        # Menghitung frekuensi kategori
        freq_data <- data() %>%
          count(.data[[selected_col]]) %>%
          arrange(desc(n))
        
        # Cek jika ada data kosong atau frekuensi 0, dan hapus kategori tersebut
        freq_data <- freq_data %>% filter(n > 0)
        
        # Membatasi kategori jika ada terlalu banyak
        if (nrow(freq_data) > 10) {
          freq_data <- head(freq_data, 10)
          freq_data[[selected_col]] <- paste(freq_data[[selected_col]], "(Top 10)")
        }
        
        # Membuat Pie Chart dengan plotly
        plot_data <- plot_ly(freq_data, labels = ~.data[[selected_col]], values = ~n, type = 'pie') %>%
          layout(title = paste("Pie Chart of", selected_col), 
                 showlegend = TRUE)
        
        # Menampilkan Pie Chart dengan plotly
        plot_data
      }
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
