# Esse código é automáticamente atualizado após rodarmos o arquivo responsável por criar as bases, 
# ou seja, precisamos rodar somente o arquivo "Gera_base.R"

library(DT)
library(shiny)
library(dplyr)
library(shinythemes)
library(magrittr)
library(rhandsontable)
library(glue)
library(lubridate)

sem <- week(ymd(today())) # pega a semana atual

base <- read.csv(glue("/home/sayuritakeda/Shiny_com_input/bases/base_",sem,".csv")) # base que foi gerada em gera_base.R 

# Cria a interface gráfica (UI) 

ui <- tagList(
  navbarPage(
    theme = shinytheme("flatly"),                   # tema de cores
    "TESTE",                                        # nome que fica no navbar (canto esquerdo)
    tabPanel("Base cars",                           # nome da primeira aba
             sidebarPanel(
               
               actionButton("saveBtn",              # nome "interno" do botão
                            "save",                 # nome que aparece no botão 
                            icon("save"),           # pode escolher a figura 
                            style="color: #fff; background-color: #001a33; border-color: #00264d"),
               
               width = 2)                           # tamanho do sidebarPanel
    ),
    
    
    mainPanel(                                      # dentro do mainPanel vamos ter 3 abas (tabPanel)
      
      width = 10,                                   # máx width = 12 
      
      tabsetPanel(
        tabPanel("TUDO",                            # nome da aba 
                 h4("Table"),                       # h4 é o tamanho da fonte 
                 rHandsontableOutput("table_total") # rhandsontable é uma tabela que lembra Excel
                 
        ),
        tabPanel("OK", 
                 h4("Table"),
                 div(dataTableOutput("table_ok"), style = "font-size:70%")  # font-size = tamanho fonte do datatable
                 
                 
        ),
        tabPanel("FALTA", 
                 h4("Table"),
                 div(dataTableOutput("table_falta"), style = "font-size:70%"))
      )
    )))



# Cria o server

server <- function(input, output) {
  
  fname = tempfile(fileext = ".csv")
  
  observe({                                    # sem essa parte não salva
    input$saveBtn
    table_total = isolate(input$table_total)
    if (!is.null(table_total)) {
      write.csv(hot_to_r(input$table_total), 
                glue("/home/sayuritakeda/Shiny_com_input/bases/base_",sem,".csv"), 
                row.names = FALSE)
      print(glue("/home/sayuritakeda/Shiny_com_input/bases/base_",sem,".csv"))
    }
  })
  
  
  output$table_total = renderRHandsontable({   # renderiza a tabela total que vai ser um rhandsontable
    
    # se não fizer isso, as células não permanecem coloridas
    DF = read.csv(glue("/home/sayuritakeda/Shiny_com_input/bases/base_",sem,".csv"), stringsAsFactors = FALSE)
    
    rhandsontable(DF) %>%
      hot_table(highlightCol = TRUE, highlightRow = TRUE) %>% 
      # deixa a "célula" colorida 
      hot_cols(renderer = "function(instance, td, row, col, prop, value, cellProperties) { 
               Handsontable.TextCell.renderer.apply(this, arguments);
               if (value == 'ok' || value == 'OK') td.style.background = 'lightblue';}")
})
  
  # se não fizer isso, a tabela ok e tabela falta não serão mais atualizadas (mesmo após atualizar)
  base_feita <- read.csv(glue("/home/sayuritakeda/Shiny_com_input/bases/base_",sem,".csv"))  # pega a base modificada
  
  
  output$table_ok = renderDataTable(                # a tabela OK vai receber a base_feita com filtro = ok
    filter(base_feita, nova == "ok" | nova == "OK")             
  )
  
  
  
  output$table_falta = renderDataTable(             # a tabela falta vai receber a base_feita com filtro diferente de ok
    filter(base_feita, nova != "ok" & nova != "OK")
  )
  }


shinyApp(ui,server)

# tem que botar OK e apertar save, depois disso a base (original) é modificada. 
# para conseguir visualizar na aba OK (para ver o que está feito) basta atualizar 
# a página (apertando F5 ou fechando e abrindo novamente)

