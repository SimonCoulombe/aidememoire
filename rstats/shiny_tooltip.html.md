---
title: "shiny tooltips using bslib"
author: Simon Coulombe
date: 2024-08-16
categories: [r, dbplyr]
lang: fr
---



from : https://rstudio.github.io/bslib/articles/tooltips-popovers/index.html

Input labels

Input labels are great place to apply what we learned in icons. They're already a common place to provide information about an input, so adding a tooltip or popover to them is a natural place to provide additional context.
```
textInput(
  inputId = "txt",
  label = tooltip(
    trigger = list(
      "Input label",
      bs_icon("info-circle")
    ),
    "Tooltip message"
  )
)
```

