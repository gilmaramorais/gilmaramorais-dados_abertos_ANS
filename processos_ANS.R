# 1. Instalar e carregar pacotes necessários
pacotes <- c("dplyr", "stringr", "lubridate")
novos <- pacotes[!(pacotes %in% installed.packages())]
if(length(novos)) install.packages(novos)
lapply(pacotes, library, character.only = TRUE)

# 2. Baixar e ler o arquivo da ANS
url <- 'https://dadosabertos.ans.gov.br/FTP/PDA/penalidades_aplicadas_a_operadoras/penalidades_aplicadas_a_operadoras.csv'
penalidades <- read.csv(url, sep = ';', header = TRUE, fileEncoding = 'WINDOWS-1252')

# 3. Selecionar colunas relevantes
penalidades <- penalidades %>%
  select(NR_DEMANDA, NR_PROCESSO, TIPO_PROCESSO, CD_OPERADORA, RAZAO_SOCIAL,
         SITUACAO_OPERADORA, STATUS_DEMANDA, DT_PUBLICACAO_1A_FINAL, 
         VL_TOTAL_APLICADO_1A, DT_PUBLICACAO_2A, TIPO_DECISAO_2A, VL_TOTAL_APLICADO_2A,
         VL_MULTA_FINAL_APLICADA, VL_TOTAL_DESCONTOS, TIPO_PENALIDADE, VL_GRU, 
         DE_SITUACAO_GRU, DT_PAGTO_A_VISTA_ANS, VL_PAGO_A_VISTA_ANS, DT_VENC_1A_PARC_ANS,
         VL_PARCELAS_ANS_PAGAS, STATUS_PARCELAMENTO, DT_INSCRICAO, ORIGEM_PAGAMENTO)

# 4. Padronizar textos e corrigir erros
penalidades$DE_SITUACAO_GRU <- str_to_title(penalidades$DE_SITUACAO_GRU)
penalidades$STATUS_PARCELAMENTO <- toupper(penalidades$STATUS_PARCELAMENTO)
penalidades$DT_VENC_1A_PARC_ANS[penalidades$DT_VENC_1A_PARC_ANS == "30/09/0222"] <- "30/09/2022"

# 5. Converter colunas de datas
penalidades <- penalidades %>%
  mutate(across(c(DT_PUBLICACAO_1A_FINAL, DT_PUBLICACAO_2A, DT_PAGTO_A_VISTA_ANS,
                  DT_VENC_1A_PARC_ANS, DT_INSCRICAO),
                ~ as.Date(., "%d/%m/%Y")))

# 6. Identificar processos repetidos
processos_repetidos <- penalidades %>%
  filter(duplicated(NR_PROCESSO) | duplicated(NR_PROCESSO, fromLast = TRUE))

# 7. Criar base única de status de parcelamento
status_parcelamento <- penalidades %>%
  select(STATUS_PARCELAMENTO) %>%
  distinct() %>%
  mutate(STATUS_PARCELAMENTO = str_to_title(STATUS_PARCELAMENTO),
         STATUS_PARCELAMENTO = ifelse(STATUS_PARCELAMENTO == "", 
                                      "Não consta (ou à vista)", 
                                      STATUS_PARCELAMENTO))






