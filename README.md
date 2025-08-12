# Linux LEMP Ubuntu 24 LTS
WSL2 manual .sh script a Linux VM running PHP 8.4, Nginx, MySQL and WordPress

## LEMP

### Installing LEMP
- After hitting enter, type your password and hit enter again to grant sudo privileges (the prompt gets lost in the scrolls)
```
wget -O - https://raw.githubusercontent.com/DesignuDev/linux-lemp-ubuntu-24-lts/refs/heads/main/setup.sh | sudo bash
```

### Installing the latest version of WordPress in the current directory
```
wget -O - https://raw.githubusercontent.com/DesignuDev/linux-lemp-ubuntu/refs/heads/main/setup-wordpress.sh | bash
```

## WSL2

### Installing WSL2 Ubuntu
- Open PowerShell as Admin.
- Type `wsl --install Ubuntu`.
- Wait for install, enter username and password.
- Done.

### Resetting WSL2 Ubuntu:
- Open PowerShell as Admin.
- Type `wsl --list` it should list your Distro as an installed distribution.
- Type `wsl --unregister Ubuntu` (if you have another Linux Distro change `Ubuntu` to whichever Distro you have).
- Type `wsl --install Ubuntu`.
- Wait for install, enter username and password.
- Done.
