alias ls='ls --color=auto'
alias reboot='sudo systemctl reboot'
alias poweroff='myRemoteDelBackup.sh && sudo systemctl poweroff'
alias mount='sudo mount'
alias umount='sudo umount'
alias pacman='sudo pacman'
alias ..='cd ..'
alias swayconf='vim ~/.config/sway/config'
alias waybarconf='vim ~/.config/waybar/config'
alias list-fonts='fc-list'
alias nvim='/usr/local/bin/nvim'
alias v='vim'
alias vim='nvim'
alias n='nvim'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias rmr='rm -rf'
alias rotEx='myRotateDisplay.sh'
alias za='zathura --fork'
alias newgradle='shopt -s dotglob && cp -r /home/simon/Documents/Templates/GradleTemplate/* . && shopt -u dotglob'
alias newluds='cp /home/simon/Documents/Templates/LUDS-ex ./ex.tex'
alias newcmake='cp -r /home/simon/Documents/Templates/CMake/* .'
alias jdoc='qutebrowser /home/simon/Documents/Documentation/docs/index.html'
alias qbc='myQbtCtrl.sh'
alias c='clear'
alias sv='source ~/.bashrc'
alias gw='./gradlew'
alias gwb='./gradlew build'
alias pud='pushd'
alias pod='popd'
alias scancp='mount -o umask=000 /dev/sdc2 /mnt/usb0 && cp /mnt/usb0/HPSCANS/scan*.pdf . && chmod 622 scan* && rm /mnt/usb0/HPSCANS/scan*.pdf && umount /dev/sdc2'
alias alide='java -jar /home/simon/Documents/Uni/Kurse/s2/SI/LowerAlpha/Bin/LowerAlpha_Java1_8.jar'
alias curl='curl -w "\n"'
alias gs='git status'
alias gti='git'
alias g='git'
alias emu='emulator @emu18 -gpu off -skin 900x1600 &'
alias emustop='killall qemu-system-x86_64'
alias cf='/home/simon/Scripts/myStartConf.sh'
