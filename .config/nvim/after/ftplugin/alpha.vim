autocmd BufWrite *.alpha :call setreg('*', expand('%:p'))
