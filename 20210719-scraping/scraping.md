## Web scraping with R

A flowchart on getting data you want. 

```mermaid
flowchart TD

1([Open devtools to the network tab])

1-->A

A[Can I access the page in my browser \n without authentication?\n i.e. incognito mode]

A-->|Yes| B[Try basic rvest read_html]

B-->|Success| C([Yay! It's a static page])

B-->|Failure| D[Inspect page URL's raw contents]

D-->|Found embedded JSON \nin main page body| E([Parse script tag \n with rvest + V8])

D-->|Could not find embedded JSON| F[Force-refresh \n while watching network tab]

F-->|Found main page cookies and headers| P[Reproduce request \n with cookies and headers]

P--> K

F-->|API/XHR request found| G[Reproduce API call,\n with headers if required]

F-->|No API request found \n and/or found a WebSocket request| H[Selenium time, imitate a browser]

H-->|Dump source to HTML| K

G-->|HTML| K([Parse HTML \n with rvest's read_html etc])

G-->|JSON| J([Parse JSON \n with jsonlite's parse_json etc])

G-->|XML| L([Parse XML \n with rvest or xml2,\n and oof])

A-->|No| F

N([Wrap code into function to iterate over URL/arguments])

C --> N
E --> N
K--> N
J --> N
L --> N
G-->|other| M([Good luck!])
```

## Preface: Scraping ethics
{insert discussion of ethics}

{via James Densmore: https://towardsdatascience.com/ethics-in-web-scraping-b96b18136f01}

> The Ethical Scraper
> 
> I, the web scraper will live by the following principles:
> 
> - If you have a public API that provides the data I’m looking for, I’ll use it and avoid scraping all together.
> - I will always provide a User Agent string that makes my intentions clear and provides a way for you to contact me with questions or concerns.
> - I will request data at a reasonable rate. I will strive to never be confused for a DDoS attack.
> - I will only save the data I absolutely need from your page. If all I need it OpenGraph meta-data, that’s all I’ll keep.
> - I will respect any content I do keep. I’ll never pass it off as my own.
> - I will look for ways to return value to you. Maybe I can drive some (real) traffic to your site or credit you in an article or post.
> - I will respond in a timely fashion to your outreach and work with you towards a resolution.
> - I will scrape for the purpose of creating new value from the data, not to duplicate it.
> 
> The Ethical Site Owner
> 
> I, the site owner will live by the following principles:
> 
> - I will allow ethical scrapers to access my site as long as they are not a burden on my site’s performance.
> - I will respect transparent User Agent strings rather than blocking them and encouraging use of scrapers masked as human visitors.
> - I will reach out to the owner of the scraper (thanks to their ethical User Agent string) before blocking permanently. A temporary block is acceptable in the case of site performance or ethical concerns.
> - I understand that scrapers are a reality of the open web.
> - I will consider public APIs to provide data as an alternative to scrapers.

## Basic rvest

Video tutorial https://www.youtube.com/watch?v=z8yT3E4pz54

Examples: 
- https://github.com/tanho63/tantorials/blob/main/20210719-scraping/scraping-limpopo.R
- https://github.com/tanho63/tantorials/blob/main/20210719-scraping/scraping-realgm.R
- https://github.com/tanho63/tantorials/blob/main/20210719-scraping/scraping-gijoe.R

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
 
https://twitter.com/_TanHo/status/1484529037460520965?s=20&t=v9KXTxfR4g-6BFU6-pHmQw

## APIs

https://github.com/tanho63/office_hours/blob/main/20210719-scraping/scraping-track.R

## Selenium

