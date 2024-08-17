---
title: "dbplyr"
description: "si simple, si compliqué.."
author: Simon Coulombe
date: 2024-08-16
categories: [r, dbplyr]
lang: fr
---



help




::: {.cell}

:::

::: {.cell}

```{.r .cell-code}
con <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

copy_to(con, nycflights13::flights, "flights",
  temporary = FALSE, 
  indexes = list(
    c("year", "month", "day"), 
    "carrier", 
    "tailnum",
    "dest"
  )
)

copy_to(con, iris, "iris",
  temporary = FALSE, 
  indexes = NULL
)
```
:::


lazy connect to the tables

::: {.cell}

```{.r .cell-code}
flights_db <- tbl(con, "flights")
iris_db <- tbl(con, "iris")
```
:::


if the table is in a schema, use dbplyr::in_schema:  
# working with schema  

To write to a table in a schema, I can use DBI::Id() and dbplyr::in_schema(), like so:  

::: {.cell}

```{.r .cell-code}
DBI::dbWriteTable(con, DBI::Id(schema = "my_schema",   table = "iris"),  value = iris, overwrite = TRUE)
iris_db <-  tbl(con,dbplyr::in_schema("my_schema","iris")) 
```
:::

note that dbWriteTable is pretty slow, consider using the `bcp` tool when working with real database.

# generate a cool sql query using dbplyr and across


::: {.cell}

```{.r .cell-code}
my_query <- iris_db %>% 
  summarise(
    across(.cols = starts_with(("Sepal")),
           .fns = list(mean = mean, min = min)
           )
    )

my_query %>% show_query()
```

::: {.cell-output .cell-output-stdout}

```
<SQL>
SELECT
  AVG(`Sepal.Length`) AS `Sepal.Length_mean`,
  MIN(`Sepal.Length`) AS `Sepal.Length_min`,
  AVG(`Sepal.Width`) AS `Sepal.Width_mean`,
  MIN(`Sepal.Width`) AS `Sepal.Width_min`
FROM `iris`
```


:::
:::


download the result from my query

::: {.cell}

```{.r .cell-code}
my_query %>% collect()
```

::: {.cell-output .cell-output-stdout}

```
# A tibble: 1 x 4
  Sepal.Length_mean Sepal.Length_min Sepal.Width_mean Sepal.Width_min
              <dbl>            <dbl>            <dbl>           <dbl>
1              5.84              4.3             3.06               2
```


:::
:::

remotely execute the query using dplyr::compute()  and save under a new name in the db.  Normally I would set "temporary = FALSE", but it doesnt work with rsqlite.

This is useful when I want to use dbplyr to generate SQL code (like using across above), but I want the processing to be done by the SQL server.  No bandwidth or CPU would be used in this case.  

::: {.cell}

```{.r .cell-code}
#compute(my_query, "my_query_output", temporary = FALSE)
compute(my_query, "my_query_output")
```

::: {.cell-output .cell-output-stdout}

```
# Source:   table<`my_query_output`> [1 x 4]
# Database: sqlite 3.45.2 [:memory:]
  Sepal.Length_mean Sepal.Length_min Sepal.Width_mean Sepal.Width_min
              <dbl>            <dbl>            <dbl>           <dbl>
1              5.84              4.3             3.06               2
```


:::

```{.r .cell-code}
my_query_output_db <- tbl(con, "my_query_output")
my_query_output_db
```

::: {.cell-output .cell-output-stdout}

```
# Source:   table<`my_query_output`> [1 x 4]
# Database: sqlite 3.45.2 [:memory:]
  Sepal.Length_mean Sepal.Length_min Sepal.Width_mean Sepal.Width_min
              <dbl>            <dbl>            <dbl>           <dbl>
1              5.84              4.3             3.06               2
```


:::
:::


# some notes on SQL translation     

  * nrow() doesnt work, use tally().  
  * unique() doesnt work, use distinct()  
  * ifelse() doesnt work, use case_when()  
  * left_join does work well with join_by()  :   
    `left_join(table_b, join_by(key_a ==  key_b)) `
  
# Azure Synapse specific stuff    

## How to list tables in a specific schema   

`
tables_available <- dbGetQuery(con,
           "SELECT table_name FROM information_schema.tables
                   WHERE table_schema='my_schema'")
`

## How to rename a table   
`
rename object my_schema.test  to test_bak ;    
`

## Dont forget to use distribution.... 

`
create table my_schema.my_sample 
with (distribution = round_robin ) as select  top 100 * from my_schema.my_full_table
`

## Insert rows    



