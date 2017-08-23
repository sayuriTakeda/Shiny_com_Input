# Esse arquivo será responsável por gerar a base (pode ser mais de uma)

setwd("/home/sayuritakeda/Shiny_com_input/")  # local com "gera_base.R", "aquivo_principal.R" e pasta "bases"

library(glue)   # para concatenar o dia nas bases geradas
library(dplyr)
library(lubridate)

base <- cars  
base %<>% mutate(nova = "n")  # insere uma coluna no final de n 

write.csv(base, glue("bases/base_",week(ymd(today())),".csv"), row.names = FALSE)  # escreve base_"semana atual" 
                                                                                   # week(ymd(today())) gera a semana atual
                                                                                   # row.names = F para não gerar a coluna index 

# a base que foi gerada:
# read.csv("/home/sayuritakeda/Shiny_com_input/bases/base_34.csv")
