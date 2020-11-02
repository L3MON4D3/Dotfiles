let g:crtFuncIndent = 4

setlocal nocindent nosmartindent indentexpr="" autoindent
setlocal foldmethod=indent
setlocal foldlevel=1
setlocal foldtext=MyFoldText()
setlocal fillchars=fold:\ ,vert:\|
setlocal foldnestmax=2

set suffixesadd=.java
set path+=**

nnoremap <buffer> <localleader>sc :so ~/.vim/java.vim<Cr>
nnoremap <buffer> <localleader>ec :tabe ~/.vim/java.vim<Cr> :tc<Cr>

function! MoveClass()
    let l:newClassname = py3eval("get_classname(vim.current.buffer)")
    let l:oldClassname = expand("%:t:s/.java//")
    if l:newClassname ==  l:oldClassname
        return
    endif
    let l:bufname = expand("%")
    let l:dir = expand("%:h")
    let l:newname = l:dir."/".l:newClassname.".java"
    call rename(l:bufname, l:newname)
    execute "edit ".l:newname
    execute "bdelete ".l:bufname
    execute "%s/".l:oldClassname."/".l:newClassname."/g"
    write
endfunction
