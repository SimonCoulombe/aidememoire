---
title: "extract actual sql code from dbplyr::show_query(), "
author: Simon Coulombe
description: |
  How to combine normal SQL code to code generated using dplyr and run everything using dbExecute  
date: 2024-08-16
format:
  html:
    code-fold: false
---


::: {.cell}

```{.r .cell-code}
library(dplyr)
library(dbplyr)
library(DBI)
library("RSQLite")
con <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
```
:::

::: {.cell}

```{.r .cell-code}
copy_to(con, iris, "iris")
```
:::

::: {.cell}

```{.r .cell-code}
iris_db <- tbl(con, "iris")
```
:::


create a query using dplyr because it is easy


::: {.cell}

```{.r .cell-code}
query_for_temp_table <- iris_db %>% 
  head(5) 

query_for_temp_table_text <- query_for_temp_table %>%
  dbplyr:::sql_render() %>%
  as.character()

query_for_temp_table_text
```

::: {.cell-output .cell-output-stdout}

```
[1] "SELECT `iris`.*\nFROM `iris`\nLIMIT 5"
```


:::
:::



let's read a "case when" query from a .sql file:  Here I put a [] around the name of Sepal.Width to deal with the dot in the field name:


::: {.cell}

```{.r .cell-code}
sepal_size_sql <-  tempfile()
writeLines(c( 'CASE',
              'WHEN [Sepal.Width] > 5 then "big"',
              'else "small"',
              'END AS sepal_size'
), sepal_size_sql)


sql_queries <- list()
sql_queries[["sepal_size"]] <- readr::read_lines(sepal_size_sql) %>%
  glue::glue_collapse(sep = "\n")

sql_queries[["sepal_size"]]
```

::: {.cell-output .cell-output-stdout}

```
CASE
WHEN [Sepal.Width] > 5 then "big"
else "small"
END AS sepal_size
```


:::
:::



create a query that applies the content of sepal_size.sql to  the output of my temp query I generated using dplyr.
note that the temp table subquery must be named using 'as sub':
note that the "sql_queries" list  could have more than 1 item.  We could read from multiple .sql files here.


::: {.cell}

```{.r .cell-code}
query_for_final_table <- glue::glue('create table final as select *,  
{paste(sql_queries, collapse = ",")}
                       from ({query_for_temp_table_text}) as sub
                       ')

query_for_final_table 
```

::: {.cell-output .cell-output-stdout}

```
create table final as select *,  
CASE
WHEN [Sepal.Width] > 5 then "big"
else "small"
END AS sepal_size
                       from (SELECT `iris`.*
FROM `iris`
LIMIT 5) as sub
```


:::
:::



run the final query using dbExecute

::: {.cell}

```{.r .cell-code}
dbExecute(con, query_for_final_table)
```

::: {.cell-output .cell-output-stdout}

```
[1] 0
```


:::
:::


It worked!
We applied the code for a "case when" we read in an .sql file to a subquery that was defined using dplyr!

::: {.cell}

```{.r .cell-code}
dbGetQuery(con, "select * from final")
```

::: {.cell-output .cell-output-stdout}

```
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species sepal_size
1          5.1         3.5          1.4         0.2  setosa      small
2          4.9         3.0          1.4         0.2  setosa      small
3          4.7         3.2          1.3         0.2  setosa      small
4          4.6         3.1          1.5         0.2  setosa      small
5          5.0         3.6          1.4         0.2  setosa      small
```


:::
:::
