setlocal foldmethod=indent
nnoremap <buffer> <localleader>ec :tabe ~/.config/nvim/after/ftplugin/cpp.vim :tc<Cr>
nnoremap <buffer> <localleader>sc :so ~/.config/nvim/after/ftplugin/cpp.vim<Cr>
nnoremap <buffer> <localleader>i :ClangdSwitchSourceHeader<Cr>

setl ai nocindent nosi
setl indentexpr=""
