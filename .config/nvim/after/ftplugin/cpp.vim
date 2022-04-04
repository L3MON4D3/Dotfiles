setlocal foldmethod=indent
nnoremap <buffer> <space>ec :tabe ~/.config/nvim/after/ftplugin/cpp.vim :tc<Cr>
nnoremap <buffer> <space>sc :so ~/.config/nvim/after/ftplugin/cpp.vim<Cr>
nnoremap <buffer> <space>i :ClangdSwitchSourceHeader<Cr>

setl ai nocindent nosi
setl indentexpr=""
