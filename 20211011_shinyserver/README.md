# How to Train Your Shiny Server

The goal of this tutorial/office hours is to demonstrate following the basic steps to installing Shiny Server Open Source directly onto a cloud server. This will generally follow a guide by Charles Bordet which can be found here: https://www.charlesbordet.com/en/guide-shiny-aws/

Preamble/background talk

- Talk briefly about pros and cons of Shiny Server vs shinyapps.io, compare with RS Cloud + rsconnect
    - NOT A SUBSTITUTE FOR A REAL DEVOPS TEAM BUT VERY USEFUL TO KNOW 
- Briefly list common cloud providers (AWS, Google Cloud Platform, Azure, DigitalOcean, Linode) and pick out the ones that have nice free tier credits
    - Also sign up for [GitHub Student Dev](https://education.github.com/pack?sort=popularity&tag=All) program if you are eligible

Coding
- Pick an app or two to put onto this server
- Talk about domains and DNS, review the basic parts of the Hover.com site and control panel
- Set up AWS account (because free tier)
- Pick out a new VM and use it
- Set up SSH + key/pair, AWS firewall
- Set up a new non-root user
- Talk about other Linux security - e.g. fail2ban, firewalls, etc
- Install R, Shiny, and RStudio on server
- Deploy app on server (w/ git + config management)
- Set up Nginx and HTTPS
- Install RStudio Server, for remote development

### Previous work and other resources

Shiny Server Guides
- Charles Bordet - https://www.charlesbordet.com/en/guide-shiny-aws/
- Dean Attali - https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/ 
- Saskia Otto - https://www.marinedatascience.co/blog/2019/04/28/run-shiny-server-on-your-own-digitalocean-droplet-part-1/

### Other related resources

Book (in progress) that aims to comprehensively discuss DevOps
- Alex Gold - DevOps for Data Science - https://akgold.github.io/do4ds/index.html

Docker (so much! next step up from the bare bones tutorial)
- Rocker! https://github.com/rocker-org/rocker-versioned2 

More examples of devops stacks
- Daniel Chen - https://github.com/chendaniely/odsc-east-2020-plumber_docker
- "" - https://github.com/bi-sdal/shy-mro-c7sd_auth/tree/master

Nginx playground - Julia Evans - https://jvns.ca/blog/2021/09/24/new-tool--an-nginx-playground/
