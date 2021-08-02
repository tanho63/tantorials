Listing various examples to tackle on stream

## R4DS scraping question

https://rfordatascience.slack.com/archives/C8K09CDNZ/p1626704301265200
```r
library(tidyverse)
# read the web page
url_data <- "https://www.dmr.gov.za/mineral-policy-promotion/operating-mines/limpopo"
# read the css selector of the data I want by defining a variable
css_selector <- "#accordion"
url_data %>%
  read_html() %>%
  html_elements(css = css_selector) %>%
  html_elements(".col-md-6") %>%
  html_text2()
```

goal: tidy dataframe

## Anthony scraping question

c/o @amicsta (twitter)

page: https://basketball.realgm.com/ncaa/players/2013/A

get all player links (and other links)

## reddit page question

(c/o u/ChocoLoco47)

https://www.reddit.com/r/Rlanguage/comments/o9tw3s/scrape_data_from_webpage_that_has_filters/

  I'm trying to scrape track and field results from the [Track & Field Results Reporting System](https://www.tfrrs.org/results_search.html) for a stats project I'm working on. I'm using the rvest package to do so. My issue is that I can't access any other year than 2021 because that's the only data displayed by the link [https://www.tfrrs.org/results_search.html](https://www.tfrrs.org/results_search.html). You can filter by year within the webpage, but it doesn't change the url, so I don't know to look at other years of data from within R. I'm pretty new to web scraping, so I'm not sure what are the right terms to describe this issue. Any advice is welcome!

Here's some basic code I've written to get the text from each of the 21 pages of meets from 2021.

```
page <- read_html("https://www.tfrrs.org/results_search.html")

tbody <- page %>%
  html_nodes("tbody")

meets <- grep("OTF", tbody, perl = TRUE)
text <- tbody[meets] %>% html_text()
```

## GI Joe database
c/o @StarTrek_LT

https://yojoe.com/action/
