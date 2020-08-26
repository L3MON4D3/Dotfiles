setlocal foldtext=MyFoldText()
setlocal fillchars=fold:\ ,vert:\|

setlocal tabstop=4
set shiftwidth=4

setlocal foldmethod=indent
nnoremap <buffer> <localleader>ec :tabe ~/.vim/cpp.vim<Cr> :tc<Cr>
nnoremap <buffer> <localleader>sc :so ~/.vim/cpp.vim<Cr>
nnoremap <buffer> <localleader>i :call SwitchImplemetationInterface()<Cr>
