function AlProCompress(){
    filename=$(pwd | perl -lpe's/.*?\/(\d+)/Ex$1.tar/g')
        (cd Java/src/main/java && \
            tar -cf ../../../../"$filename" *.java && \
            cd ../../../.. && \
            tar -rf "$filename" $1)
}

function vProj_gen() {
	echo "source /home/simon/.config/nvim/$1.vim" >> .vProj.vim
}
