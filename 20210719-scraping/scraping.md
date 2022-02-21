## Scraping with R

A flowchart on getting data you want. 

```mermaid
flowchart TD

A[Can I access it in my browser without authentication?]

A-->|Yes| B[Try rvest]

B-->|Success| C[Yay! It's a static table.]

B-->|Failure| D[Open network tab to inspect page URL's raw contents]

D-->|Found embedded JSON| E[Parse script tag with V8]

D-->|Could not find embedded JSON| F[Ctrl-F5 and see if there are API requests]

F-->|API request found!| G[API time.] --> J

F-->|Websocket request found!| H[Selenium time.]

A-->|No| I[Look for API]

I-->|API found| J[API]

I-->|No API found| H[Selenium time]

```

