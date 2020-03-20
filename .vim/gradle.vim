function! New_j_term()
    exec "call term_start('bash',{'term_name':'".t:termname."','term_finish':'close','curwin': 1,'out_cb':'Jdb_handler'})"
endfunction

function! Task(command)
    wa
    if !bufexists(t:termname)
        let l:filename = expand('%')
        call New_j_term()
        execute "sbuffer ".l:filename
    endif
    execute "call term_sendkeys(\"" . t:termname . "\", \"\<c-u>" . a:command . "\<Cr>\")"
endfunction

function! Run_java()
    call Task(t:runTask)
endfunction

function! Debug_java()
    wa
    call Task(t:debugTask)
    let t:debugWait = 1
endfunction

function! Jdb_handler(channel, message)
    if t:debugWait
        if a:message =~ 'Listening for transport dt_socket at address: 5005'
            let t:debugWait = 0
            JDBAttach
        endif
    endif
endfunction

let t:termname = 'jTerm: '.Get_term_name()

let t:runTask = "gradle run -q"
let t:debugTask = "gradle run --debug-jvm -q"
let t:buildTask = "gradle build -q"
let t:testTask = "gradle test -q"
let t:installTask = "gradle installDebug -q"

let t:args = ""
let t:debugWait = 0
let t:srcDir = "*/src/main/java"

nnoremap <buffer><silent> <F1> :JDBBreakpointOnLine<Cr>
nnoremap <buffer><silent> <S-F1> :JDBClearBreakpointOnLine<Cr>
nnoremap <buffer><silent> <F2> :call Debug_java()<Cr>
nnoremap <buffer><silent> <S-F2> :JDBDetach<Cr>
nnoremap <buffer><silent> <F3> :JDBStepOver<Cr>
nnoremap <buffer><silent> <S-F3> :JDBStepIn<Cr>
nnoremap <buffer><silent> <F4> :JDBStepUp<Cr>
nnoremap <buffer><silent> <F5> :let g:curPos = winsaveview()<Cr> :call Run_java()<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <S-F5> :let g:curPos = winsaveview()<Cr> :call Task(t:buildTask)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <F6> :let g:curPos = winsaveview()<Cr> :call Task(t:testTask)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <F7> :let g:curPos = winsaveview()<Cr> :call Task(t:installTask)<Cr> :call winrestview(g:curPos)<Cr>

nnoremap <buffer> <localleader>e :execute edit

if filereadable('.vProj.vim')
    source .vProj.vim
endif

cabbr <expr> %% t:srcDir
