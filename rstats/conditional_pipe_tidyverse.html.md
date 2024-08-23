---
title: "conditionally execute something in a tidyverse pipe"
author: Simon Coulombe
description: |
  Welcome to {} hell
date: 2024-08-16
format:
  html:
    code-fold: false
---



I just always forget this one.. you need to wrap the {if} inside the {}

::: {.cell}

```{.r .cell-code}
library(dplyr)
iris %>% head() %>%
  {
    if (TRUE) {
      dplyr::select(., contains("Sepal")) %>% 
      dplyr::mutate(., addition = Sepal.Length + Sepal.Width )
    } else {.}
  }
```

::: {.cell-output .cell-output-stdout}

```
  Sepal.Length Sepal.Width addition
1          5.1         3.5      8.6
2          4.9         3.0      7.9
3          4.7         3.2      7.9
4          4.6         3.1      7.7
5          5.0         3.6      8.6
6          5.4         3.9      9.3
```


:::
:::

::: {.cell}

```{.r .cell-code}
iris %>% head() %>%
  {
    if (FALSE) {
      dplyr::select(., contains("Sepal")) %>% 
      dplyr::mutate(., addition = Sepal.Length + Sepal.Width )
    } else {.}
  }
```

::: {.cell-output .cell-output-stdout}

```
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species
1          5.1         3.5          1.4         0.2  setosa
2          4.9         3.0          1.4         0.2  setosa
3          4.7         3.2          1.3         0.2  setosa
4          4.6         3.1          1.5         0.2  setosa
5          5.0         3.6          1.4         0.2  setosa
6          5.4         3.9          1.7         0.4  setosa
```


:::
:::
