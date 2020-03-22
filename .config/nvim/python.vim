let t:args = ""
let t:switchToRunTerm = 0

function! Open_documentation(keyword)
    execute "let l:ret = system('pydoc3" a:keyword "')"
    redir! > ~/.cache/vim/doc
        echo l:ret
    redir END
    pedit +setlocal\ bufhidden=delete ~/.cache/vim/doc
endfunction

function! Run_python()
    execute "let l:filename = \"" . expand('%') . "\""
    let l:termname = Get_term_name()
    call New_term(l:termname, l:filename)
    execute "call term_sendkeys(\"" . l:termname . "\", \"python3 " . l:filename  t:args . "\<Cr>\")"
    if t:switchToRunTerm 
        execute "sbuffer" l:filename
    endif
endfunction

noremap <buffer> [15~ :silent execute Run_python()<Cr>

noremap <buffer> <Leader>d :silent let g:curPos = winsaveview()<Cr> :silent execute Open_documentation(expand('<cword>'))<Cr>:silent call winrestview(g:curPos)<Cr>
