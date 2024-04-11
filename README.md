# linux-LEMP-ubuntu-22
quick setup for a linux vm running php 7.4, nginx, mysql and wordpress

### installation
- after hitting enter, type your password and hit enter again to grant sudo privileges
  (the prompt gets lost in the scrolls)
```
wget -O - https://raw.githubusercontent.com/icarus-gg/linux-LEMP-ubuntu-22/main/ubuntu-22-lemp.sh | sudo bash
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