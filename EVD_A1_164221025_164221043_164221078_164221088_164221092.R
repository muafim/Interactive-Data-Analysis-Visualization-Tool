library(shiny)
library(shinydashboard)
library(DT)
library(shinythemes)
library(dplyr)
library(ggplot2)
library(VIM)
library(visdat)
library(rsconnect)

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "UAS EVD KELOMPOK 5"),
  dashboardSidebar(
    sidebarMenu(
      menuItem('Input Data', tabName = 'input_data', icon = icon("download")),
      menuItem("Pendahuluan", tabName = "pendahuluan", icon = icon("book-open")),
      menuItem("Statistika Deskriptif", tabName = "statdes", icon = icon("pie-chart")),
      menuItem("Data Preprocessing", tabName = "preprocessing", icon = icon("gear")),
      menuItem("Visualisasi Data", tabName = "visual", icon = icon("chart-line")),
      menuItem("Analisis Data", tabName = "analisis", icon = icon("search")),
      menuItem("Kesimpulan dan Saran", tabName = "kesimpulan", icon = icon("bug"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
                .skin-black .main-header .logo { background-color: #0c1112; }
                .skin-black .main-header .navbar { background-color: #0c1112; }
                .main-sidebar, .left-side { background-color: #0c1112; }
            "))
    ),
    tabItems(
      tabItem(
        tabName = 'input_data',
        h2(strong('Input Data')),
        fileInput('file', 'Unggah File CSV'),
        actionButton('load_data', 'Tampilkan Data'),
        DTOutput('data_terupload'),
        fluidRow(
          column(12,
                 tags$hr(),
                 h2(strong("Variabel Penelitian"), align = "center"),
                 tags$hr(),  # Horizontal line for separation
                 
                 # Umur
                 h4("Umur"),
                 p("Usia responden."),
                 
                 # Jenis alat transportasi
                 h4("Jenis Alat Transportasi"),
                 p("Moda transportasi yang digunakan oleh responden, seperti kendaraan pribadi, kendaraan umum, dan ojek online."),
                 
                 # Jenis kendaraan
                 h4("Jenis Kendaraan"),
                 p("Jenis kendaraan yang digunakan, seperti motor, mobil, dan lainnya. 'Lainnya' merujuk pada bus UNAIR, kereta api, dan jenis transportasi umum lain."),
                 
                 # Tingkat performa
                 h4("Tingkat Performa"),
                 p("Seberapa baik performa kendaraan yang digunakan oleh responden. Terdapat tiga tingkatan performa: kurang baik, baik, dan sangat baik."),
                 
                 # Tingkat mobilitas
                 h4("Tingkat Mobilitas"),
                 p("Frekuensi penggunaan kendaraan oleh responden. Variabel ini berbentuk skala dari 1-10."),
                 
                 # Biaya transportasi
                 h4("Biaya Transportasi"),
                 p("Biaya yang dikeluarkan oleh responden dalam hal transportasi, seperti bensin, biaya ojol, dan tiket."),
                 
                 # Jarak
                 h4("Jarak"),
                 p("Jarak tempat tinggal responden ke kampus."),
                 
                 # Waktu
                 h4("Waktu"),
                 p("Waktu yang ditempuh dari tempat tinggal responden ke kampus."),
                 
                 # Gender
                 h4("Gender"),
                 p("Jenis kelamin responden.")
          )
        )
      ),
      tabItem(tabName = "pendahuluan",
              
              tags$div(
                style = "border: 2px solid #0c1112; padding: 10px;",
                h4(strong("Dibuat oleh:")),
                h5("Meri Agustina (164221025)"),
                h5("Najla Dhia Rusydi (164221043)"),
                h5("Shiba Salsabilla (164221078)"),
                h5("Ramadhan Eko Saputra (164221088)"),
                h5("Muhammad Firdaus Mu’afi (164221092)"),
                tags$hr(),
                h4(strong("Latar Belakang"), align = "center"),
                h5(HTML("Dalam era modern dan globalisasi, keberadaan alat transportasi telah menjadi unsur krusial dalam kehidupan seorang mahasiswa. 
                        Transportasi memainkan peran penting dalam mobilitas dan aksesibilitas. Keberagaman alat transportasi, mulai dari kendaraan pribadi dan kendaraan umum menjadi bagian tak terpisahkan dari rutinitas sehari-hari mahasiswa. 
                        Mobilitas mahasiswa tidak hanya terbatas pada kehadiran di kampus namun juga interaksi sosial lainnya di luar lingkup kampus. Pentingnya mobilitas dan penggunaan alat transportasi ini memberikan dampak langsung terhadap pengeluaran mahasiswa. 
                        Sebagian besar mahasiswa menghadapi tantangan dalam memilih alat transportasi yang sesuai dengan kebutuhan dan anggaran mereka. Penggunaan kendaraan pribadi, seperti motor atau mobil, dapat memberikan kenyamanan tetapi juga memerlukan pengeluaran untuk perawatan dan bahan bakar. 
                        Sementara itu, penggunaan transportasi umum mungkin lebih ekonomis, tetapi bisa melibatkan waktu perjalanan lebih lama dan penyesuaian dengan jadwal transportasi yang terbatas. Analisis mendalam terhadap penggunaan alat transportasi terhadap pengeluaran mahasiswa angkatan 2022 menjadi perlu untuk memahami bagaimana pilihan transportasi ini mempengaruhi aspek keuangan mahasiswa. 
                        Penelitian ini bertujuan untuk mengidentifikasi pola penggunaan alat transportasi yang dominan di kalangan mahasiswa, menjelajahi faktor-faktor yang memengaruhi pilihan mereka, dan menganalisis korelasi antara jenis alat transportasi dan besaran pengeluaran mahasiswa. Dengan memperoleh wawasan ini, diharapkan penelitian dapat memberikan manfaat dalam menyusun panduan kebijakan di tingkat perguruan tinggi untuk meningkatkan aksesibilitas, efisiensi, dan kesejahteraan mahasiswa. 
                        Informasi yang diperoleh juga dapat membantu mahasiswa dalam mengambil keputusan cerdas terkait dengan penggunaan alat transportasi yang sesuai dengan kebutuhan dan kemampuan ekonomi mereka. Dengan demikian, penelitian ini akan menjadi kontribusi penting untuk meningkatkan kualitas kehidupan dan pengelolaan keuangan mahasiswa angkatan 2022."), align = "justify"),
                tags$hr(),
                h4(strong("Rumusan Masalah"), align = "center"),
                h5(HTML("1. Berapa besar pengeluaran rata-rata mahasiswa Teknologi Sains Data angkatan 2022 untuk transportasi dalam kurun waktu satu minggu?"), align = "justify"),
                h5(HTML("2. Apa jenis transportasi yang paling dominan digunakan oleh mahasiswa Teknologi Sains Data angkatan 2022 dalam aktivitas sehari-hari mereka?"), align = "justify"),
                h5(HTML("3. Bagaimana korelasi dari faktor-faktor yang memiliki tipe data numerik terhadap biaya yang dikeluarkan oleh mahasiswa Teknologi Sains Data angkatan 2022?"), align = "justify"),
                h5(HTML("4. Bagaimana korelasi dari faktor-faktor yang memiliki tipe data kategorik terhadap biaya yang dikeluarkan oleh mahasiswa Teknologi Sains Data angkatan 2022?"), align = "justify"),
                h5(HTML("5. Bagaimana korelasi antar variabel yang ada?"), align = "justify"),
                
                tags$hr(),
                h4(strong("Manfaat Penelitian: 
                          "), align = "center"),
                h5(HTML("1. Penelitian ini dapat memberikan wawasan kepada pengguna transportasi, khususnya mahasiswa Teknologi Sains Data sebagai bahan referensi sarana transportasi paling optimal"), align = "justify"),
                h5(HTML("2. Penelitian ini memberikan pandangan yang lebih rinci tentang pengeluaran masing-masing sarana transportasi (kendaraan pribadi, ojek online, dan kendaraan umum. Hal ini dapat membantu mahasiswa Teknologi Sains Data dalam membantu memilih sarana transportasi yang lebih optimal sesuai dengan preferensi pengeluaran  dan kebutuhan mahasiswa Teknologi Sains Data"), align = "justify")

                
                
              )
      ),
      
      
      tabItem(tabName = "statdes", 
              h2(strong("Statistika Deskriptif"), align = "center"),
              tabsetPanel(
                tabPanel("Summary",icon=icon("align-justify"),
                         column(12, align = "middle",
                                selectInput(inputId="deskriptif","",
                                            list("umur", "jenis_kendaraan_lainnya", "waktu", "biaya", "tingkat_mobilitas"),selected = "umur" ),
                                verbatimTextOutput("summary")),
                         column(12,
                                column(4,align= "niddle",style = "border-right: 1px solid black;",
                                       fluidRow(h4(" ")),
                                       fluidRow(h5("Mean"),textOutput("mean")),
                                       fluidRow(h5("Median"),textOutput("median"))),
                                column(4,align= "middle",style = "border-right: 1px solid black;",
                                       fluidRow(h4(" ")),
                                       fluidRow(h5("Max"),textOutput("max")),
                                       fluidRow(h5("Min"),textOutput("min"))),
                                column(4,align= "middle",style = "border-right: 1px solid black;",
                                       fluidRow(h4(" ")),
                                       fluidRow(h5("Variance"),textOutput("var")),
                                       fluidRow(h5("Std. Deviation"),textOutput("std"))))),
                
                tabPanel("Bar Chart",icon=icon("chart-simple"),
                         selectInput(inputId = "variable", label = "Pilih Variabel", choices = NULL),
                         plotOutput(outputId = "barchart")),
                tabPanel("Pie Chart", icon = icon("pie-chart"),
                         plotOutput(outputId = "piechart")),
                tabPanel("Density", icon = icon("density"),
                         plotOutput(outputId = "density")),
                tabPanel("Scatter Plot", icon = icon("arrow-up-right-dots"),
                         selectInput(inputId="scatter", 
                                     h3(strong("Scatter Plot
                                               dengan Y = Biaya")),
                                     list("gender", "transportasi", "jenis_kendaraan", "umur", "performa_kendaraan", "tingkat_mobilitas", "biaya", "jarak", "waktu"), selected = "gender"),
                         mainPanel(
                           plotOutput("scatter_plot")
                         )
                )
                
              )
      ),
      tabItem(tabName = "preprocessing",
              tags$div(
                style = "height: 260vh;",
                h2(strong("Data Preprocessing"), align = "center"),
                tabsetPanel(
                  tabPanel("Check Missing Value",
                           plotOutput("missingvalue"),
                           h4("\nInterpretasi"),
                           h5(HTML("Pada visualisasi checking value tidak ditemukan sama sekali data yang hilang atau tidak terisi, karena dataset yang diajukan menggunakan pertanyaan yang wajib diisi."), align = "justify")
                  ),
                  tabPanel("Checking Outlier",
        
                           h2("Boxplot sebelum dan sesudah penghapusan outlier variabel numerik menggunakan pendekatan IQR"),
                           plotOutput("hapusoutlier"),
                           plotOutput("outlierPlot"),
                           tableOutput("outlierTable")
                  ),
                  tabPanel("Dimensi Reduksi",
                           h2('Dimensi Reduksi'),
                           selectInput('correlation_var1', 'Pilih Variabel Pertama:', choices = NULL),
                           selectInput('correlation_var2', 'Pilih Variabel Kedua:', choices = NULL),
                           verbatimTextOutput('dimensi_reduksi'),
                           plotOutput("scree_plot"),
                           plotOutput("biplot")
                  ),
                  tabPanel("Transformasi",
                           h4(HTML("Pada dataset yang kami gunakan saat ini sudah melalui beberapa tahap transformasi data, transformasi data ini bertujuan agar dataset yang kami gunakan tidak bias dan mendapatkan nilai yang sesungguhnya dari jawaban-jawaban yang sampel kami berikan."), align = "justify"),
                           h5(strong('1. Transformasi pada variabel Jenis Kendaraan')),
                           fluidRow(
                             column(3, align="right",
                                    img(src="https://cdn.discordapp.com/attachments/1107359977703735319/1189503360596983848/Screenshot_207.png")),
                             column(1, align="center",
                                    div(img(src="https://cdn.discordapp.com/attachments/866347997910269993/1049604804206415952/arrow_right_icon_128385.png", height=100, width=100))),
                             column(3, align="left",
                                    div(img(src="https://cdn.discordapp.com/attachments/1107359977703735319/1189504703562788904/Screenshot_2023-12-27_161201.png?ex=659e6795&is=658bf295&hm=b9686d1d753d3ba444fe6fe58051b9e7dfab769ae3bc50c8c45354787dc530ca&"))
                             )),
                           h4(HTML("Variabel jenis kendaraan merupkan variabel kategorikal sehingga kami melakukan transformasi untuk memudahkan menjadi bentuk yang dapat diolah oleh algoritma machine learning atau statistik "), align = "justify"),
                           h5(strong('2. Transformasi pada variabel Transportasi')),
                           fluidRow(
                             column(3, align="right",
                                    img(src="https://cdn.discordapp.com/attachments/1107359977703735319/1189519246447874118/Screenshot_2023-12-27_174315.png?ex=659e7520&is=658c0020&hm=1a0b5002627b711caac1805240ad23a2ed08f5b803bb7e70441c1b6b9fa8264d&g")),
                             column(1, align="center",
                                    div(img(src="https://cdn.discordapp.com/attachments/866347997910269993/1049604804206415952/arrow_right_icon_128385.png", height=100, width=100))),
                             column(3, align="left",
                                    div(img(src="https://cdn.discordapp.com/attachments/1107359977703735319/1189519246691160127/Screenshot_2023-12-27_174338.png?ex=659e7520&is=658c0020&hm=ee9d3f915788e97c888b833845279c44483c06c51171a77556ba20e33e47cb9a&"))
                             )),
                           h4(HTML("Sama seperti variabel jenis kendaraan, variabel transportasi juga merupakan variabel kategorik sehingga kami melakukan transformasi dengan metode encoding agar mudah dipahami saat melakukan analisis"), align = "justify"),
                           h5(strong('3. Transformasi pada variabel Gender')),
                           fluidRow(
                             column(3, align="right",
                                    img(src="https://cdn.discordapp.com/attachments/1107359977703735319/1189522983363018813/Screenshot_2023-12-27_175923.png?ex=659e789b&is=658c039b&hm=bd8ce56e99ccdd91c59743650a814e3dd9c8673e375d77086e76701256eac26d&")),
                             column(1, align="center",
                                    div(img(src="https://cdn.discordapp.com/attachments/866347997910269993/1049604804206415952/arrow_right_icon_128385.png", height=100, width=100))),
                             column(3, align="left",
                                    div(img(src="https://cdn.discordapp.com/attachments/1107359977703735319/1189523129039589437/Screenshot_2023-12-27_180000.png?ex=659e78be&is=658c03be&hm=d597cf3460accb1f50b5d22c4f307e83e3089eda3e83a81ad31ca861832a104c&"))
                                    
                             )),
                           h4(HTML("Untuk variabel gender kami melakukan transformasi karena variabel gender merupakan variabel kategorik sehingga dapat memudahkan saat melakukan analisa"), align = "justify"),
                           h5(strong('4. Transformasi pada variabel performa kendaraan')),
                           fluidRow(
                             column(3, align="right",
                                    img(src="https://cdn.discordapp.com/attachments/1107359977703735319/1189526343436742696/Screenshot_2023-12-27_181140.png?ex=659e7bbc&is=658c06bc&hm=e32c751151ec8548231caa8ce0a62c48627eab4ca9cbe5e5ea5af0ee5e0a69f7&")),
                             column(1, align="center",
                                    div(img(src="https://cdn.discordapp.com/attachments/866347997910269993/1049604804206415952/arrow_right_icon_128385.png", height=100, width=100))),
                             column(3, align="left",
                                    div(img(src="https://cdn.discordapp.com/attachments/1107359977703735319/1189526343671619654/Screenshot_2023-12-27_181219.png?ex=659e7bbc&is=658c06bc&hm=58534bf4b07014aac3b9f4115a72587b67e3508a67145ced757ff9752f21d6d7&"))
                             )),
                           h4(HTML("variabel performa kendaraan juga merupakan variabel kategorik yang memiliki 2 kategori (Sangat Baik, Baik) sehingga kami melakukan transformasi"), align = "justify"),
                           
                                    
                           
                           
                           
                           
                           
                           
                           plotOutput("transformasi")
                  )
                )
              )
      ),
      
      tabItem(
        tabName = 'visual',
        h2(strong('Visualisasi Data'), align = "center"),
        h5(HTML('Pada menu kali ini kami memberikan visualisasi kepada variabel yang diiginkan untuk divisualisasikan dengan variabel X dan variabel Y yang ada pada dataset'), align = "justify"),
        fluidRow(
          box(selectInput('x_var', 'Pilih Variabel X :', choices = NULL),
              selectInput('y_var', 'Pilih Variabel Y :', choices = NULL),
              uiOutput('bin_ui')),
          box(plotOutput('plot1'))
        )
      ),
      tabItem(tabName = "analisis",
              h2(strong("Analisis Data"), align = "center"),
              tabsetPanel(
                tabPanel("Uji Tau-Kendall",
                         tags$img(src = "https://drive.google.com/uc?export=view&id=12inSSZLD6T8LBr6pmQE8U3K6d3Nfh9bD", height = "auto", width = "100%"),
                         tags$div(
                           style = "border: 2px solid #0c1112; padding: 10px;",
                           
                           h4(strong("Interpretasi : ")),
                           h5(HTML("Berdasarkan tabel diatas dapat kita lihat bahwa P-Value dari variabel umur lebih kecil dibandingkan alpha (0.05), yang artinya terdapat korelasi antara biaya yang dikeluarkan dengan umur. 
                              Untuk nilai τ menandakan sebesar apa korelasi yang dimiliki antara biaya dengan faktor yang diduga sebagai  sedangkan umur memiliki nilai korelasi negatif lemah, yang artinya ketika seseorang memiliki umur lebih mudah terdapat sedikit kemungkinan mengeluarkan biaya transportasi yang lebih tinggi, dan berikut merupakan visualisasi korelasi antara  biaya dengan umur mahasiswa TSD2022."), align = "justify")
                         )
                ),
                tabPanel("Uji Kruskal-Wallis",
                         tags$img(src = "https://drive.google.com/uc?export=view&id=1hibHG7c0xof36kPurZEikN4am5EiTdkg", height = "auto", width = "100%"),
                         tags$div(
                           style = "border: 2px solid #0c1112; padding: 10px;",
                           
                           h4(strong("Interpretasi :")),
                           h5(HTML("Berdasarkan hasil perhitungan Kruskal-Wallis yang dilakukan, ditemukan bahwa terdapat perbedaan yang signifikan dalam biaya antara jenis transportasi yang berbeda. 
                              Namun, untuk variabel lain seperti gender, jenis kendaraan, dan performa kendaraan, tidak terdapat bukti yang cukup untuk menegaskan adanya perbedaan yang signifikan dalam biaya antara kategori yang berbeda pada variabel-variabel tersebut."), align = "justify")
                         )
                ),
                tabPanel("Korelasi Heatmap",
                         tags$img(src = "https://drive.google.com/uc?export=view&id=1T3nFZPNlDNodDRk7u5mn17FayHuMA1tw", height = "auto", width = "100%"),
                         tags$div(
                           style = "border: 2px solid #0c1112; padding: 10px;",
                           
                           h4(strong("Interpretasi :")),
                           h5(HTML("Untuk korelasi positif yang merupakan 3 nilai terbesar adalah jenis kendaraan mobil dan biaya (0.55), kemudian transportasi umum dengan jenis kendaraan lainnya (0.5), dan gender laki-laki dengan waktu (0.35). 
                              Sementara itu untuk korelasi dengan 3 nilai paling kecil adalah gender perempuan dengan gender laki-laki (-1), transportasi ojek online dengan transportasi kendaraan pribadi(-0.92), dan performa kendaraan sangat baik dan performa kendaraan baik (-0.77)."), align = "justify")
                         )
                )
              )
      ),
      
      tabItem(tabName = "kesimpulan",
              tabsetPanel(
                tabPanel("Kesimpulan",
                         tags$div(
                           style = "border: 2px solid #0c1112; padding: 10px;",
                           
                           h4(strong("Kesimpulan")),
                           h5(HTML("Berdasarkan visualisasi dan hasil uji yang telah dilakukan, didapatkan beberapa kesimpulan sebagai berikut: "), align = "justify"),
                           h5(HTML("Berdasarkan visualisasi pie chart, mahasiswa Teknologi Sains Data angkatan 2022 sebesar 71,1% menggunakan kendaraan pribadi dan sebesar 85,5% menggunakan kendaraan motor."), align = "justify"),
                           h5(HTML("Berdasarkan visualisasi korelasi heatmap, variabel yang memiliki korelasi paling tinggi dengan variabel biaya adalah jenis kendaraan mobil, yaitu sebesar positif 55% dan korelasi paling rendah pada variabel jenis kendaraan motor, yaitu sebesar negatif  5%."), align = "justify"),
                           h5(HTML("Berdasarkan hasil uji Saphiro Wilk, dataset ini memiliki distribusi yang tidak normal, sehingga dilakukan uji analisis Tau Kendall dan Uji Kruskal Walls untuk melihat hubungan signifikan tiap variabel dengan variabel biaya."), align = "justify")
                         )
                ),
                tabPanel("Saran",
                         tags$div(
                           style = "border: 2px solid #0c1112; padding: 10px;",
                           
                           h4(strong("Saran")),
                           h5(HTML("Adapun beberapa saran yang dapat bermanfaat sebagai acuan dan membangun pada peneliti yang ingin mengembangkan lebih dalam lagi untuk memperluas pemahaman ilmu yang didapatkan selanjutnya sebagai berikut:"), align = "justify"),
                           h5(HTML("1. Menambah jumlah populasi sehingga sampel yang didapatkan menjadi lebih banyak. Hal tersebut dapat berpengaruh pada distribusi data yang memungkinkan untuk berdistribusi normal."), align = "justify"),
                           h5(HTML("2. Menambahkan variabel faktor yang memungkinkan berpengaruh terhadap biaya pengeluaran."), align = "justify"),
                           h5(HTML("3. Mempertimbangkan penggunaan metode analisis lain yang dapat memberikan hasil analisis lebih kompleks."), align = "justify"),
                           h5(HTML("4. Mempertimbangkan metode transformasi data yang lain seperti normalisasi, transformasi logaritmik, atau reduksi dimensi menggunakan teknik seperti Principal Component Analysis (PCA)."), align = "justify")
                         )
                )
              )
      )
    )
  ),
  skin = "purple"
)

server <- function(input, output, session) {
  
  uploaded_data <- reactive({
    req(input$file)
    read.csv(input$file$datapath, row.names = NULL)
  })
  
  data_types <- reactive({
    data.frame(
      Variable = names(uploaded_data()),
      Type = sapply(uploaded_data(), class)
    )
  })
  
  output$data_terupload <- renderDT({
    datatable(uploaded_data())
  })
  
  output$data_types <- renderDataTable({
    datatable(data_types(), options = list(pageLength = 5))
  })
  observeEvent(input$file, {
    tryCatch({
      output$data_terupload <- renderDT({
        datatable(uploaded_data())
      })
      # Assuming num_col is the numeric columns of the uploaded data
      updateSelectInput(session, 'correlation_var1', choices = colnames(uploaded_data())[sapply(uploaded_data(), is.numeric)])
      updateSelectInput(session, 'correlation_var2', choices = colnames(uploaded_data())[sapply(uploaded_data(), is.numeric)])
    }, error = function(e) {
      print(paste("Error in observeEvent:", e$message))
    })
  })
  
  # Update choices for variable selection
  observe({
    updateSelectInput(session, 'variable', choices = colnames(uploaded_data()))
  })

  observe({
    updateSelectInput(session, 'x_var', choices = colnames(uploaded_data()))
    updateSelectInput(session, 'y_var', choices = colnames(uploaded_data()))
  })

  num_col <- reactive({
    sapply(uploaded_data(), is.numeric)
  })

  output$bin_ui <- renderUI({
    if (!is.null(input$x_var) & !is.null(input$y_var)) {
      num_col_x <- num_col()[input$x_var]
      num_col_y <- num_col()[input$y_var]

      if (num_col_x) {
        numericInput("bin", "bin", value = 10, min = 0, max = 100)
      } else if (num_col_y) {
        numericInput("bin", "bin", value = 10, min = 0, max = 100)
      }
    }
  })

  output$plot1 <- renderPlot({
    req(input$x_var, input$y_var)
    ggplot(uploaded_data(), aes_string(x = input$x_var, y = input$y_var)) +
      geom_point(size = 2) +
      theme(axis.text = element_text(size = 8),
            axis.title = element_text(size = 12),
            plot.title = element_text(size = 15, face = "bold"))
  })

  # Data Statistika Deskriptif
  datastatdes <- reactive({
    newdata <- uploaded_data() %>% select(input$deskriptif)
  })

  # Mean
  output$mean <- renderPrint({
    mean(as.numeric(unlist(datastatdes())))
  })

  # Median
  output$median <- renderPrint({
    median(as.numeric(unlist(datastatdes())))
  })

  # Variance
  output$var <- renderPrint({
    var(as.numeric(unlist(datastatdes())))
  })

  # Max
  output$max <- renderPrint({
    max(as.numeric(unlist(datastatdes())))
  })

  # Min
  output$min <- renderPrint({
    min(as.numeric(unlist(datastatdes())))
  })

  # Std Dev
  output$std <- renderPrint({
    sd(as.numeric(unlist(datastatdes())))
  })

  # Histogram
  output$barchart <- renderPlot({
    if (!is.null(input$variable)) {
      # Check the type of the selected variable
      variable_type <- typeof(uploaded_data()[[input$variable]])

      if (variable_type == "integer" | variable_type == "double") {
        # For numeric variables
        ggplot(uploaded_data(), aes(x = .data[[input$variable]])) +
          geom_histogram(fill = "cornflowerblue", color = "black", bins = 30) +
          labs(x = input$variable, y = "Frequency", title = "Histogram")
      } else {
        # For categorical variables
        ggplot(uploaded_data(), aes(x = factor(.data[[input$variable]]))) +
          geom_bar(fill = "cornflowerblue", color = "black") +
          labs(x = input$variable, y = "Frequency", title = "Histogram")
      }
    }
  })

  # Pie Chart
  output$piechart <- renderPlot({
    if (!is.null(input$variable)) {
      # Check if the selected variable exists in the dataset
      if (input$variable %in% colnames(uploaded_data())) {
        # Check the type of the selected variable
        variable_type <- typeof(uploaded_data()[[input$variable]])

        if (variable_type != "integer" & variable_type != "double") {
          # Filter out missing values before creating the pie chart
          non_missing_data <- na.omit(uploaded_data()[[input$variable]])

          # Check if there are non-missing values
          if (length(non_missing_data) > 0) {
            pie_data <- table(non_missing_data)
            pie_labels <- names(pie_data)

            pie_df <- data.frame(labels = pie_labels, values = as.numeric(pie_data))

            ggplot(pie_df, aes(x = "", y = values, fill = labels)) +
              geom_bar(stat = "identity", width = 1, color = "white") +
              coord_polar(theta = "y") +
              labs(title = paste("Pie Chart for", input$variable))
          } else {
            # Handle the case when all values are missing
            plot(NULL, xlim = c(0, 1), ylim = c(0, 1), 
                 main = "All values are missing for the selected variable",
                 xlab = "", ylab = "")
          }
        } else {
          # Handle the case when the selected variable is numeric
          # You can provide an alternative plot or an informative message
          plot(NULL, xlim = c(0, 1), ylim = c(0, 1), 
               main = "Selected variable is numeric; Pie Chart requires categorical variable",
               xlab = "", ylab = "")
        }
      } else {
        # Handle the case when the selected variable doesn't exist
        plot(NULL, xlim = c(0, 1), ylim = c(0, 1), 
             main = "Selected variable does not exist in the dataset",
             xlab = "", ylab = "")
      }
    }
  })

  # Scatter Plot
  output$scatter_plot <- renderPlot({
    req(input$variable)  # Only render when the "Update Plot" button is clicked

    scat <- input$scatter
    ggplot(data = uploaded_data(), aes_string(x = scat, y = "biaya")) +
      geom_point() +
      geom_smooth(method = lm)
  })

  # Checking missing value
  output$missingvalue <- renderPlot({
    # Create a visual representation of missing values
    vis_miss(uploaded_data())
  })

  
  # Checking Outlier
  output$outlier <- renderPlot({
    uas_numeric <- uploaded_data() %>%
      select_if(function(x) is.numeric(x))
    par(mfrow = c(1, 5))
    for (i in 1:5) {
      boxplot(uas_numeric[, i], main = names(uas_numeric)[i])
    }
  })
  
  # Hapus Outlier
  output$hapusoutlier <- renderPlot({
    uas_numeric <- uploaded_data() %>%
      select_if(is.numeric)
    
    # Function to remove outliers based on IQR
    remove_outliers_iqr <- function(column) {
      Q1 <- quantile(column, 0.25)
      Q3 <- quantile(column, 0.75)
      IQR_val <- Q3 - Q1
      lower_bound <- Q1 - 1.5 * IQR_val
      upper_bound <- Q3 + 1.5 * IQR_val
      column[column >= lower_bound & column <= upper_bound]
    }
    
    # Remove outliers for each numeric column
    uas_numeric_no_outliers <- lapply(uas_numeric, remove_outliers_iqr)
    
    # Create boxplots for columns without outliers
    par(mfrow = c(1, 5))
    for (i in 1:5) {
      boxplot(uas_numeric_no_outliers[[i]], main = names(uas_numeric_no_outliers)[i])
    }
  })
  
  
  
  # Histogram
  output$barchart <- renderPlot({
    if (!is.null(input$variable)) {
      # Check the type of the selected variable
      variable_type <- typeof(uploaded_data()[[input$variable]])
      
      if (variable_type == "integer" | variable_type == "double") {
        # For numeric variables
        ggplot(uploaded_data(), aes(x = .data[[input$variable]])) +
          geom_histogram(fill = "cornflowerblue", color = "black", bins = 30) +
          labs(x = input$variable, y = "Frequency", title = "Histogram")
      } else {
        # For categorical variables
        ggplot(uploaded_data(), aes(x = factor(.data[[input$variable]]))) +
          geom_bar(fill = "cornflowerblue", color = "black") +
          labs(x = input$variable, y = "Frequency", title = "Histogram")
      }
    }
  })
  
  # Pie Chart
  output$piechart <- renderPlot({
    if (!is.null(input$variable)) {
      # Check if the selected variable exists in the dataset
      if (input$variable %in% colnames(uploaded_data())) {
        # Filter out missing values before creating the pie chart
        non_missing_data <- na.omit(uploaded_data()[[input$variable]])
        
        if (length(non_missing_data) > 0) {
          if (is.numeric(non_missing_data)) {
            # For numeric variables, create a histogram instead of a pie chart
            ggplot(uploaded_data(), aes(x = .data[[input$variable]])) +
              geom_histogram(fill = "cornflowerblue", color = "black", bins = 30) +
              labs(x = input$variable, y = "Frequency", title = "Histogram for Numeric Variable")
          } else {
            # For categorical variables
            pie_data <- table(non_missing_data)
            pie_labels <- names(pie_data)
            
            pie_df <- data.frame(labels = pie_labels, values = as.numeric(pie_data))
            
            ggplot(pie_df, aes(x = "", y = values, fill = labels)) +
              geom_bar(stat = "identity", width = 1, color = "white") +
              coord_polar(theta = "y") +
              labs(title = paste("Pie Chart for", input$variable))
          }
        } else {
          # Handle the case when all values are missing
          plot(NULL, xlim = c(0, 1), ylim = c(0, 1), 
               main = "All values are missing for the selected variable",
               xlab = "", ylab = "")
        }
      } else {
        # Handle the case when the selected variable doesn't exist
        plot(NULL, xlim = c(0, 1), ylim = c(0, 1), 
             main = "Selected variable does not exist in the dataset",
             xlab = "", ylab = "")
      }
    }
  })
  
  output$density <- renderPlot({
    if (!is.null(input$variable)) {
      # Check if the selected variable exists in the dataset
      if (input$variable %in% colnames(uploaded_data())) {
        # Filter out missing values before creating the density plot
        non_missing_data <- na.omit(uploaded_data()[[input$variable]])
        
        if (length(non_missing_data) > 0 && is.numeric(non_missing_data)) {
          # For numeric variables, create a density plot
          ggplot(uploaded_data(), aes(x = .data[[input$variable]])) +
            geom_density(fill = "skyblue", color = "black") +
            labs(x = input$variable, y = "Density", title = "Density Plot for Numeric Variable")
        } else {
          # Handle the case when the variable is not numeric
          plot(NULL, xlim = c(0, 1), ylim = c(0, 1), 
               main = "Density plot is applicable only for numeric variables",
               xlab = "", ylab = "")
        }
      } else {
        # Handle the case when the selected variable doesn't exist
        plot(NULL, xlim = c(0, 1), ylim = c(0, 1), 
             main = "Selected variable does not exist in the dataset",
             xlab = "", ylab = "")
      }
    }
  })
  
  
  # Scatter Plot
  output$scatter_plot <- renderPlot({
    req(input$variable)  # Only render when the "Update Plot" button is clicked
    
    scat <- input$scatter
    ggplot(data = uploaded_data(), aes_string(x = scat, y = "biaya")) +
      geom_point() +
      geom_smooth(method = lm)
  })
  
  # Checking missing value
  output$missingvalue <- renderPlot({
    # Create a visual representation of missing values
    vis_miss(uploaded_data())
  })
  
  
  
  # Hapus Outlier
  output$hapusoutlier <- renderPlot({
    uas_numeric <- uploaded_data() %>%
      select_if(is.numeric)
    
    # Function to remove outliers based on IQR
    remove_outliers_iqr <- function(column) {
      Q1 <- quantile(column, 0.25)
      Q3 <- quantile(column, 0.75)
      IQR_val <- Q3 - Q1
      lower_bound <- Q1 - 1.5 * IQR_val
      upper_bound <- Q3 + 1.5 * IQR_val
      column[column >= lower_bound & column <= upper_bound]
    }
    
    # Remove outliers for each numeric column
    uas_numeric_no_outliers <- lapply(uas_numeric, remove_outliers_iqr)
    
    # Create boxplots for columns without outliers
    par(mfrow = c(1, 5))
    for (i in 1:5) {
      boxplot(uas_numeric_no_outliers[[i]], main = names(uas_numeric_no_outliers)[i])
    }
  })
  
  # Display outlier plot
  output$outlierPlot <- renderPlot({
    uas_numeric <- uploaded_data() %>%
      select_if(is.numeric)
    
    # Function to identify outliers based on IQR
    identify_outliers_iqr <- function(column) {
      Q1 <- quantile(column, 0.25)
      Q3 <- quantile(column, 0.75)
      IQR_val <- Q3 - Q1
      lower_bound <- Q1 - 1.5 * IQR_val
      upper_bound <- Q3 + 1.5 * IQR_val
      outliers <- column[column < lower_bound | column > upper_bound]
      data.frame(Outliers = outliers)
    }
    
    # Identify outliers for each numeric column
    outlier_data <- lapply(uas_numeric, identify_outliers_iqr)
    
    # Create boxplots with identified outliers
    par(mfrow = c(1, 5))
    for (i in 1:5) {
      boxplot(uas_numeric[[i]], main = names(uas_numeric)[i], outline = FALSE)
      points(x = rep(1, length(outlier_data[[i]]$Outliers)), y = outlier_data[[i]]$Outliers, col = "red", pch = 16)
    }
  })
  
  # Display outlier table
  # Display outlier table
  output$outlierTable <- renderTable({
    uas_numeric <- uploaded_data() %>%
      select_if(is.numeric)
    
    # Function to identify outliers based on IQR
    identify_outliers_iqr <- function(column, col_name) {
      Q1 <- quantile(column, 0.25)
      Q3 <- quantile(column, 0.75)
      IQR_val <- Q3 - Q1
      lower_bound <- Q1 - 1.5 * IQR_val
      upper_bound <- Q3 + 1.5 * IQR_val
      outliers <- column[column < lower_bound | column > upper_bound]
      data.frame(Column = col_name, Outliers = ifelse(length(outliers) > 0, toString(outliers), "None"))
    }
    
    # Identify outliers for each numeric column
    outlier_data <- lapply(names(uas_numeric), function(col) {
      identify_outliers_iqr(uas_numeric[[col]], col)
    })
    
    # Combine outlier data into a single table
    combined_outliers <- do.call(rbind, outlier_data)
    
    # Return the combined outliers table
    combined_outliers
  
  })
  
  # gatau bagian apa (males mikir)
  output$normality_result <- renderText({
    req(uploaded_data())
    
    # Pilih kolom yang diinginkan
    selected_column <- uploaded_data()[[input$selected_column]]
    
    # Check if the selected column is numeric
    if (is.numeric(selected_column)) {
      # Perform the Shapiro-Wilk test
      shapiro_test_result <- shapiro.test(selected_column)
      
      # Menampilkan hasil uji normalitas
      if (shapiro_test_result$p.value > 0.05) {
        return("Kesimpulan: Tidak cukup bukti untuk menolak H0. Data terdistribusi normal.")
      } else {
        return("Kesimpulan: H0 ditolak. Data tidak terdistribusi normal.")
      }
    } else if (is.factor(selected_column) | is.character(selected_column)) {
      # Handle the case where the column is categorical
      # Convert categorical variable to numeric (one-hot encoding or other methods)
      # For example, using as.numeric for illustration (you may need to choose a suitable encoding method)
      encoded_column <- as.numeric(factor(selected_column))
      
      # Perform the Shapiro-Wilk test on the encoded column
      shapiro_test_result <- shapiro.test(encoded_column)
      
      # Menampilkan hasil uji normalitas
      if (shapiro_test_result$p.value > 0.05) {
        return("Kesimpulan: Tidak cukup bukti untuk menolak H0. Data terdistribusi normal.")
      } else {
        return("Kesimpulan: H0 ditolak. Data tidak terdistribusi normal.")
      }
    } else {
      # Handle the case where the column is neither numeric nor categorical
      return("Kesimpulan: Kolom yang dipilih tidak bersifat numerik atau kategorik.")
    }
  })
  
  # Dimensi Reduksi
  # Dimensi Reduksi
  output$dimensi_reduksi <- renderPrint({
    correlation_var1 <- input$correlation_var1
    correlation_var2 <- input$correlation_var2
    
    if (!is.null(uploaded_data()) && 
        !is.null(correlation_var1) && correlation_var1 != "" &&
        !is.null(correlation_var2) && correlation_var2 != "" &&
        correlation_var1 != correlation_var2 &&
        correlation_var1 %in% colnames(uploaded_data()) &&
        correlation_var2 %in% colnames(uploaded_data())) {
      
      # Assuming correlation_var1 and correlation_var2 are numeric columns
      data_for_pca <- uploaded_data()[, c(correlation_var1, correlation_var2)]
      
      # Perform PCA
      pca_result <- prcomp(data_for_pca, center = TRUE, scale. = TRUE)
      
      # Print summary of PCA
      cat("Summary of Principal Component Analysis:\n")
      print(summary(pca_result))
      
      # Scree plot
      cat("\nScree Plot:\n")
      output$scree_plot <- renderPlot({
        scree_data <- as.data.frame(pca_result$sdev^2 / sum(pca_result$sdev^2))
        rownames(scree_data) <- c("PC1", "PC2")
        colnames(scree_data) <- c("Proportion of Variance")
        
        barplot(scree_data$`Proportion of Variance`, main = "Scree Plot", xlab = "Principal Component", ylab = "Proportion of Variance")
      })
      
      # Biplot
      cat("\nBiplot:\n")
      output$biplot <- renderPlot({
        biplot(pca_result)
      })
    }
    
    
  })
}

shinyApp(ui, server)
