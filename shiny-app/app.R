# Optional lightweight Shiny counterpart. Run locally: shiny::runApp("shiny-app")
# Exported with Shinylive for static hosting under public/shiny/.
library(shiny)
d <- read.csv("data/data-baru.csv", stringsAsFactors = FALSE)
d$performa_kendaraan[d$performa_kendaraan == "Kurang Baik"] <- "Kurang baik"
clean <- d
for (col in names(clean)[vapply(clean, is.numeric, logical(1))]) {
  q <- quantile(clean[[col]], c(.25, .75))
  clean <- clean[clean[[col]] >= q[1] - 1.5 * diff(q) & clean[[col]] <= q[2] + 1.5 * diff(q), ]
}
money <- function(x) paste0("Rp", format(round(x), big.mark = ".", scientific = FALSE, trim = TRUE))
ui <- fluidPage(
  tags$head(tags$style(HTML("body{font-family:system-ui;background:#F7F8FA;color:#172033;max-width:1100px;margin:auto} .well{background:white;border:1px solid #E4E7EC;border-radius:4px} h1{font-size:25px} h3{font-size:17px} .nav-tabs>li.active>a{color:#0F766E}"))),
  h1("Student Transportation & Mobility Analytics"),
  p("Transportation choices, travel behavior, and spending among TSD 2022 students"),
  selectInput("mode", "Transportation mode", c("All modes" = "", sort(unique(d$transportasi)))),
  tabsetPanel(
    tabPanel("Overview", h3("Survey snapshot"), verbatimTextOutput("overview")),
    tabPanel("Transportation", h3("Mode distribution"), plotOutput("modes"), h3("Vehicle type"), plotOutput("vehicles")),
    tabPanel("Spending", h3("Cost distribution"), plotOutput("costs"), h3("Cost by mode"), plotOutput("boxes")),
    tabPanel("Relationships", selectInput("x", "X variable", c("Distance"="jarak", "Travel time"="waktu", "Mobility score"="tingkat_mobilitas", "Age"="umur")), plotOutput("scatter")),
    tabPanel("Statistics", h3(paste("Full cleaned sample, n =", nrow(clean))), verbatimTextOutput("tests")),
    tabPanel("Data Quality", h3("Preprocessing"), verbatimTextOutput("quality"))
  ),
  tags$hr(), p("Observational, small sample; public transport has only two respondents. No causal or population-wide inference is intended.")
)
server <- function(input, output, session) {
  current <- reactive(if (input$mode == "") d else d[d$transportasi == input$mode, ])
  output$overview <- renderPrint({ x <- current(); cat("Respondents:", nrow(x), "\nMedian cost:", money(median(x$biaya)), "\nMedian distance:", median(x$jarak), "km\nMedian time:", median(x$waktu), "min\n") })
  output$modes <- renderPlot(barplot(table(current()$transportasi), horiz=TRUE, col="#2563EB", las=1, xlab="Respondents"))
  output$vehicles <- renderPlot(barplot(table(current()$jenis_kendaraan), horiz=TRUE, col="#0F766E", las=1))
  output$costs <- renderPlot({ hist(current()$biaya, col="#2563EB", border="white", main="", xlab="Reported cost (Rp)"); abline(v=median(current()$biaya), col="#D97706", lwd=2) })
  output$boxes <- renderPlot(boxplot(biaya ~ transportasi, data=current(), col="#DBEAFE", las=2, ylab="Cost (Rp)", main="Filtered descriptive data"))
  output$scatter <- renderPlot({ x <- current(); plot(x[[input$x]], x$biaya, col=as.integer(factor(x$transportasi)), pch=19, xlab=input$x, ylab="Cost (Rp)") })
  output$tests <- renderPrint({
    cat("Shapiro–Wilk (cleaned numeric):\n")
    for (name in names(clean)[vapply(clean, is.numeric, logical(1))]) cat(name, ":", signif(shapiro.test(clean[[name]])$p.value, 4), "\n")
    cat("\nKruskal–Wallis (cost by mode):\n"); print(kruskal.test(biaya ~ transportasi, data=clean))
    cat("\nKendall τ with cost:\n")
    for (name in setdiff(names(clean)[vapply(clean, is.numeric, logical(1))], "biaya")) {
      test <- suppressWarnings(cor.test(clean$biaya, clean[[name]], method="kendall", exact=FALSE))
      cat(name, ": τ =", round(unname(test$estimate), 3), ", p =", signif(test$p.value, 4), "\n")
    }
  })
  output$quality <- renderPrint({ cat("Raw rows:", nrow(d), "\nMissing cells:", sum(is.na(d)), "\nCleaned rows:", nrow(clean), "\nOutliers removed:", nrow(d)-nrow(clean), "\nMethod: sequential 1.5 × IQR.\n") })
}
shinyApp(ui, server)
