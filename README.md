# linux-LEMP-ubuntu-22
WSL2 manual, .sh script, && docker-compose setups for a linux vm running php 7.4, nginx, mysql and wordpress

## docker-compose
- prerequs download and install `docker desktop for windows` or docker + docker-compose for linux
- cmd into root directory and run `docker-compose up` 
- visit `http://localhost:8080` 

### modifying files inside docker container(s) directly from VSCODE
- download `Dev Containers` vscode plugin -> https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
- after you run `docker-compose up` open the Dev Container vs code dashboard, it will auto-detect any running containers [in this case you should see "DEV VOLUMES" -> 
- right click `linux-lemp-ubuntu-22_wordpress` and select `EXPLORE IN DEV CONTAINER`
- that will take a bit to load and then you will be able to modify all files and have immediate updates to the wordpress site(s)

## WSL2

### installation of LEMP without wordpress:
- after hitting enter, type your password and hit enter again to grant sudo privileges
  (the prompt gets lost in the scrolls)
```
wget -O - https://raw.githubusercontent.com/icarus-gg/linux-LEMP-ubuntu-22/seperate-bash-files/ubuntu-22-lemp.sh | sudo bash
```

### installation
- after hitting enter, type your password and hit enter again to grant sudo privileges
  (the prompt gets lost in the scrolls)
```
wget -O - https://raw.githubusercontent.com/icarus-gg/linux-LEMP-ubuntu-22/seperate-bash-files/ubuntu-22-lemp-wordpress.sh | sudo bash
```

### resetting wsl2 ubuntu:
- start > Ubu -> right click and `Uninstall` > confirm
- open microsoft store 
  - if on searching `Ubuntu` shows `Installed`, close and reopen again until it shows `Install` on hover
- open Powershell as admin
```
wsl -l -v
// look for `Ubuntu-XX.XX`
wsl --unregister Ubuntu-XX.XX`
```
- re-check your `Start` > `Ubu` doesn't return any results to `Ubuntu XX` app
  - if it does, right click it and select `Uninstall` and reclick the start menu until it disappears.
- reopen microsoft store and search `Ubuntu`
- click `Install` on Ubuntu XX -> (note it may still show `Owned` but when you hover over it should show `Install`)