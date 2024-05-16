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

### Installing WSL2 Ubuntu
- Open PowerShell as Admin.
- Type `wsl --install Ubuntu`.
- Wait for install, enter username and password.
- Done.

### Installing LEMP:
- After hitting enter, type your password and hit enter again to grant sudo privileges (the prompt gets lost in the scrolls)
```
wget -O - https://raw.githubusercontent.com/icarus-gg/linux-LEMP-ubuntu-22/seperate-bash-files/ubuntu-22-lemp.sh | sudo bash
```

### Installing Wordpress (Not needed if you already have a wordpress site)
- After hitting enter, type your password and hit enter again to grant sudo privileges (the prompt gets lost in the scrolls)
```
wget -O - https://raw.githubusercontent.com/icarus-gg/linux-LEMP-ubuntu-22/seperate-bash-files/ubuntu-22-lemp-wordpress.sh | sudo bash
```

### Resetting WSL2 Ubuntu:
- Open PowerShell as Admin.
- Type `wsl --list` it should list your Distro as an installed distribution.
- Type `wsl --unregister Ubuntu` (if you have another Linux Distro change `Ubuntu` to whichever Distro you have).
- Type `wsl --install Ubuntu`.
- Wait for install, enter username and password.
- Done.