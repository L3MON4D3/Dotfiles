let t:execName = "build/a.out"
let t:args = ""

let t:run = t:execName." ".t:args

set makeprg=make
set autowrite

let t:srcDir = "src"

nnoremap <buffer><silent> <localleader>r :execute "!".t:run." ".t:args<Cr>
nnoremap <buffer><silent> <localleader>b :make!<Cr>
nnoremap <buffer><silent> <localleader>i :call SwitchImplemetationInterface()<Cr>

cabbr <expr> %% t:srcDir
cabbr <expr> %m t:srcDir."/main.c"
