let t:args = ""
let t:run = "python3 ".expand('%')." ".t:args

set makeprg=python3

nnoremap <buffer><silent> <space>r :exec ':Dispatch python3 ' expand('%')<Cr>

if filereadable('.vProj.vim')
    source .vProj.vim
endif
