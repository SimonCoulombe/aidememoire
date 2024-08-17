---
title: "Create a table in an azure synapse schema distribution round_robin"
date: "2024-08-16"
format:
  html:
    code-fold: false
---


  
```bash
create table my_schema.my_sample 
  with (distribution = round_robin ) as select  top 100 * from my_schema.my_full_table;")
```


