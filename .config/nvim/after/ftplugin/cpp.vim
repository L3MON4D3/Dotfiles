setlocal foldtext=MyFoldText()
setlocal fillchars=fold:\ ,vert:\|

setlocal foldmethod=indent
nnoremap <buffer> <localleader>ec :tabe ~/.vim/cpp.vim<Cr> :tc<Cr>
nnoremap <buffer> <localleader>sc :so ~/.vim/cpp.vim<Cr>
nnoremap <buffer> <localleader>i :CocCommand clangd.switchSourceHeader<Cr>

setl ai nocindent nosi
setl indentexpr=""
