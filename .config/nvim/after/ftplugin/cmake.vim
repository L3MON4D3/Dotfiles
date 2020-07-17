function! Run_cpp()
    wa
    execute "let l:filename = \"" . expand('%') . "\""
    let l:termname = Get_term_name()
    call New_term(l:termname, l:filename)
    "splice to remove linefeed appended by system()
    let l:exename = system("cat src/CMakeLists.txt \| grep add_executable \| perl -lpe's/add_executable\\((.*)/$1/g'")[:-2]
    execute "call term_sendkeys(\"" . l:termname . "\", \"./build/src/" . l:exename t:args . "\<Cr>\")"
endfunction

function! Test_cpp()
    wa
    execute "let l:filename = \"" . expand('%') . "\""
    let l:termname = Get_term_name()
    call New_term(l:termname, l:filename)
    "splice to remove linefeed appended by system()
    let l:exename = system("cat test/CMakeLists.txt \| grep add_executable \| perl -lpe's/add_executable\\((.*)/$1/g'")[:-2]
    execute "call term_sendkeys(\"" . l:termname . "\", \"./build/test/" . l:exename . "\<Cr>\")"
endfunction

function! Compile_cpp()
    wa
    execute "let l:filename = \"" . expand('%') . "\""
    let l:termname = Get_term_name()
    call New_term(l:termname, l:filename)
    execute "call term_sendkeys(\"" . l:termname . "\", \"make -C build\<Cr>\")"
endfunction

function! Remake_cpp()
    wa
    execute "let l:filename = \"" . expand('%') . "\""
    let l:termname = Get_term_name()
    call New_term(l:termname, l:filename)
    execute "call term_sendkeys(\"" . l:termname . "\", \"cmake -B build\<Cr>\")"
endfunction

let t:args = ""

setlocal nocindent nosmartindent indentexpr="" autoindent

nnoremap <buffer><silent> <F5> :let g:curPos = winsaveview()<Cr>:execute Run_cpp()<Cr>:call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <S-F5> :let g:curPos = winsaveview()<Cr>:execute Compile_cpp()<Cr>:call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <F6> :let g:curPos = winsaveview()<Cr>:execute Test_cpp()<Cr>:call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <F4> :let g:curPos = winsaveview()<Cr>:execute Remake_cpp()<Cr>:call winrestview(g:curPos)<Cr>
