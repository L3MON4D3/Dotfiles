alias poweroff='myRemoteDelBackup.sh && sudo systemctl poweroff'
alias poweroff='myRemoteDelBackup.sh && sudo systemctl poweroff'
alias za='zathura --fork'
alias newgradle='shopt -s dotglob && cp -r /home/simon/Documents/Templates/GradleTemplate/* . && shopt -u dotglob'
alias newluds='cp /home/simon/Documents/Templates/LUDS-ex ./ex.tex'
alias newcmake='cp -r /home/simon/Documents/Templates/CMake/* .'
alias newmake='cp -r /home/simon/Documents/Templates/makeTemplate/* .'
alias qbc='myQbtCtrl.py'
complete -F _myQbtCtrl qbc
alias sv='source ~/.bashrc'
alias gw='./gradlew'
alias gwb='./gradlew build'
alias scancp='mount -t vfat -o umask=000 /dev/sdc1 /mnt/ex0/ && cp /mnt/ex0/HPSCANS/scan*.pdf . && chmod 622 scan* && rm /mnt/ex0/HPSCANS/scan*.pdf && umount /dev/sdc1'
alias emu='emulator @emu18 -gpu off -skin 900x1600 &'
alias emustop='killall qemu-system-x86_64'
alias cf='/home/simon/Scripts/myStartConf.sh'
alias scsh='grim -g "$(slurp)" screen.png'
alias sued='/home/simon/Scripts/mySudoEdit.sh'
alias p='paru -Syu; myUpdateRemote.sh'
source /usr/share/bash-completion/completions/paru.bash
complete -F _paru p
alias myRemoteDelBackup.sh='myRemoteBackup.sh --delete'
alias myRemoteDelSync.sh='myRemoteSync.sh --delete'
alias lock='cmatrix -abLu 3'
alias lstyc='stylua -c $(find . -name "*.lua")'
alias e='exa'
alias ea='exa -a'
alias el='exa -l'
alias ela='exa -la'
alias et='exa --tree'
alias etl='exa --tree -l'
alias etla='exa --tree -la'
