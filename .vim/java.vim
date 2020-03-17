let g:crtFuncIndent = 4

setlocal nocindent nosmartindent indentexpr="" autoindent
setlocal foldmethod=indent
setlocal foldlevel=1
setlocal fillchars=fold:\ ,vert:\|
setlocal foldnestmax=2
setlocal foldtext=MyFoldText()

nnoremap <buffer> <localLeader>dc :JDBCommand 
nnoremap <buffer> <localleader>sc :so ~/.vim/java.vim<Cr>
nnoremap <buffer> <localleader>ec :tabe ~/.vim/java.vim<Cr> :tc<Cr>
nnoremap <buffer> <leader>c :let g:curPos = getcurpos()<Cr> I//<Esc> :call cursor(g:curPos[1:])<Cr>
