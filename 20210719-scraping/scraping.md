## Scraping with R

A flowchart on getting data you want. 

```mermaid
flowchart TD

A[Can I access it in my browser without authentication?]

A-->|Yes| B[Try rvest]

B-->|Success| C[Yay! It's a static table.]

B-->|Failure| D[Open network tab to inspect page URL's raw contents]

A-->|No| F

D-->|Found embedded JSON| E[Parse script tag with V8]

D-->|Could not find embedded JSON| F[Ctrl-F5 and see if there are API requests]

F-->|API request found!| G[API time.]

F-->|No API request found and/or found a WebSocket request| H[Selenium time.]

```

## Basic rvest

## Embedded JSON with V8

```r
library(jsonlite)
library(V8)
library(rvest)
library(tidyverse)

page_html <- rvest::read_html("http://www4.vestibular.ufjf.br/2021/notaspism1/H.html")

script_tags <- page_html |> 
  html_elements("script") |> 
  html_text2() |> 
  str_subset("testdata") |> 
  str_replace_all("\\r","") |> 
  str_replace_all(".+ var (testdata .*)","\\1")

js <- V8::v8()

js$eval(script_tags)

testdata <- js$get("testdata") 

data_test <- testdata$data |> 
  unnest(modulosPISM)
 ```

## APIs

## Selenium

