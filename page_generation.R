library(tidyverse)
library(glue)

map(list.files("texts"), function(i){
  
  readxl::read_xlsx(str_c("texts/", i)) %>% 
    mutate_all(function(x){ifelse(is.na(x), "", x)}) ->
    df
  
  file_name <- unique(df$file_name)
  
  "
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE)
library(tippy)
```
  " %>% 
    write_lines(str_c(file_name, ".Rmd"))
  
  str_c("## ", unique(df$doc_id), "\n\n::: {dir=rtl}\n\n") %>% 
    write_lines(str_c(file_name, ".Rmd"), append = TRUE)
  
  df %>% 
    fill(paragraph_id, sentence_id, sentence, term_id, token_id) %>% 
    mutate(tooltip = str_c(lemma, "<br>", upos,"<br>", feats)) %>% 
    group_by(paragraph_id, sentence_id, sentence, term_id, token_id, token) %>% 
    summarise(tooltip = str_c(tooltip, collapse = "<br>")) %>% 
    glue_data('`r tippy("{token}", tooltip = "{tooltip}")`')  %>% 
    write_lines(str_c(file_name, ".Rmd"), append = TRUE)
  
  ":::\n\n" %>% 
    write_lines(str_c(file_name, ".Rmd"), append = TRUE)
  
  "## Словарь\n\n::: {dir=rtl}\n\n" %>% 
    write_lines(str_c(file_name, ".Rmd"), append = TRUE)
  
  str_c(df$lemma, df$meaning) %>% 
    unique() %>%
    sort() %>% 
    str_c(collapse = "; ") %>% 
    write_lines(str_c(file_name, ".Rmd"), append = TRUE)
  
  ":::\n\n" %>% 
    write_lines(str_c(file_name, ".Rmd"), append = TRUE)
})
