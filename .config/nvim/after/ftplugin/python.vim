let t:args = ""
let t:run = "python3 ".expand('%')." ".t:args

set makeprg=python3

nnoremap <buffer><silent> <localleader>r :call Exec_term(t:run." ".t:args)<Cr>

if filereadable('.vProj.vim')
    source .vProj.vim
endif
