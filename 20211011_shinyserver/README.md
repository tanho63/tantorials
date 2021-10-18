# How to Train Your Shiny Server

The goal of this tutorial/office hours is to demonstrate following the basic steps to installing Shiny Server Open Source directly onto a cloud server. This will generally follow a guide by Charles Bordet with some chunks taken from Dean Attali's guide and from my own experiences. Guides linked below. Highly recommend reading Charles's guide - does a great job explaining mechanics approachably!

### Video

- Cleaned up/edited version - https://youtu.be/JL4T0qfqY7k - thank you so much to Alyssa for helping with the editing!

### Preamble/background notes

- Talk briefly about pros and cons of Shiny Server vs shinyapps.io, compare with RS Cloud + rsconnect
    - Knowing how to set your own server up is an important step in your growth as a shiny developer!
- Common cloud providers are AWS, Google Cloud Platform, Azure, DigitalOcean, and Linode. The big three (AWS/GCP/Azure) have nice free tiers you should look at to get started with.
- Also consider signing up for [GitHub Student Dev](https://education.github.com/pack?sort=popularity&tag=All) program if you are eligible
- Choice of Linux distro: I just recommend using Ubuntu 20.04 - that's the long-term stable release and ***by far*** the most common distribution, which means it'll be the easiest to get help online with. The performance gains between OSes are marginal compared to just buying more resources for your VM. You may want to upgrade to a newer Ubuntu eventually but it's a bunch of (relatively unnecessary) work. 

### Coding Outline and Notes
- Pick an app or two to put onto this server
    - We'll use https://github.com/dynastyprocess/apps-potentialpoints 
- Buy a domain
    - https://tan.fyi
- Set up AWS account (because free tier is nice)
- Pick out a new VM and use it
    - AWS t2.micro with Ubuntu 20.04 (free tier + current long-term-stable Ubuntu version) 
    - In general I just recommend using Ubuntu everywhere, there are reasons to choose other ones but they're mostly irrelevant to new devops people
- Set up SSH + key/pair, AWS firewall
    - On Windows, this involves configuring Putty
    - AWS comes with a web-based firewall, I like to configure it so that only my IP can access the box via SSH
    - Azure and GCP also have web-based firewalls, Digital Ocean and Linode I'm unfamiliar with (they may not)
- Access the VM with SSH
- Helpful Linux shell commands and keyboard shortcuts
    -  `Ctrl-C` does *not* copy - it runs a "kill currently running command" operation
    -  `Ctrl-Ins` is copy
    -  `Shift-Ins` is paste
    -  `.` refers to the current working directory
    -  `..` refers to the parent directory of whatever is the current working directory
    -  `cd` is change directory - when run without an argument it takes you to your home directory (`/home/tan` etc)
    -  `ls` is "list files" - I like `ls -al` which lists all files in a vertical list
    -  `ln -s` is "create symbolic link" - this command creates references between one folder/file location to another, and allows the system to treat the file as if it existed in the new location
    -  `sudo` refers to "super user do" - it performs admin-level/permission commands

- Set up a new non-root user
    -  `sudo adduser tan` add a new user named tan (also configure password)
    -  `sudo gpasswd -a tan sudo` (make this user have sudo permissions)
    -  `sudo su tan` switch user to `tan`

- Add other Linux security (optional/recommended)
    - fail2ban is an easy one (not covered in video) `sudo apt install fail2ban` 

- Add swap space (virtual memory) <- ***especially important if you're on a free tier VM - your R packages will not install otherwise***
    - here, 2GB of swap 
    ```
    sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=2048 
    sudo /sbin/mkswap /var/swap.1
    sudo /sbin/swapon /var/swap.1
    sudo sh -c 'echo "/var/swap.1 swap swap defaults 0 0 " >> /etc/fstab'
    ```
    
- Install R
    - https://cran.rstudio.com/bin/linux/ubuntu/ are the official instructions for installing R - relevant parts snipped here:
    ```
    apt update -qq
    apt install --no-install-recommends software-properties-common dirmngr
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
    apt install --no-install-recommends r-base r-base-dev
    ```
    - r-base-dev is important, don't skip it!
- Install R packages
    - There is a difference between your personal package library and the library that Shiny will have access to. It's important to always install packages into the root user's library!
    - I like pak (pak pak pak pak) https://drive.google.com/file/d/10ekbUxKsKmEPjk0Z6G4BDoPwV4sa8oWG/view?usp=sharing
    - I didn't do this in the video and regretted it, but you can use RSPM to speed things up https://packagemanager.rstudio.com/client/#/repos/1/overview
    - If something fails to install, check the requirements with pak::pkg_system_requirements(pkg, execute = TRUE) - hopefully that's the problem with the package!
    
    ```
    sudo R
    # in R console
    install.packages("pak", repos = "https://r-lib.github.io/p/pak/dev/")
    # use RSPM - I forgot to and I think this will make it go faster
    options(repos = c("CRAN" = "https://packagemanager.rstudio.com/all/__linux__/focal/latest"))
    pkgs <- c("shiny","dplyr","tidyr","rmarkdown","shinyWidgets")
    lapply(pkgs, function(pkg) {
      pak::pkg_system_requirements(pkg, execute = TRUE)
    })
    pak::pak(pkgs) # hopefully this doesn't take very long!
    q() # exit
    ``
- Install Shiny Server and RStudio Server
  - install both as per instructions here https://www.rstudio.com/products/rstudio/download-server/debian-ubuntu/ and https://www.rstudio.com/products/shiny/download-server/ubuntu/
- Deploy app on server (w/ git + config management)
    - git clone the repo to your base folder and symlink into /srv/shiny-server 
- Set up Nginx
    - `sudo apt install nginx`
    - Copied from Charles Bordet and Dean Attali's tutorial - the following goes in /etc/nginx/sites-available/shiny.conf
    ```
    server {
    # listen 80 means the Nginx server listens on the 80 port.
    listen 80;
    listen [::]:80;
    # Replace it with your (sub)domain name.
    server_name shiny.datachamp.fr;
    # The reverse proxy, keep this unchanged:
    location / { # for the basic shiny server
        proxy_pass http://localhost:3838;
        proxy_redirect http://localhost:3838/ $scheme://$host/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_read_timeout 20d;
        proxy_buffering off;
    }
    location /rstudio/ {
        proxy_pass http://127.0.0.1:8787/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
     }
    }
    ```
    and this gets added to /etc/nginx/nginx.conf inside of the http block 
    ```
    map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
    } 
    ```
   - then test nginx `sudo nginx -t` 
   - and restart nginx to apply changes `sudo systemctl restart nginx`
- Set up HTTPS with Certbot
  - As per instructions here: https://certbot.eff.org/
  ```
  sudo snap install core; sudo snap refresh core
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
  sudo certbot --nginx
  ```

Poof you now have a shiny app server and a remote R environment. Video forthcoming. 

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
