---
title: "Rename a table in an azure synapse schema"
date: "2024-08-16"
format:
  html:
    code-fold: false
---


  
```bash
dbExecute(con,"rename object my_schema.test  to test_bak ;")
```


