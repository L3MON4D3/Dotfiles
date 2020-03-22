function! New_j_term()
    enew
    let t:termchannel=termopen('bash', {'on_exit':'JTermClose','on_stdout':'Jdb_handler'})
endfunction

function! JTermClose(job_id, data, event)
    unlet t:termchannel
endfunction

function! Task(command)
    wa
    if !exists('t:termchannel')
        let l:filename = expand('%')
        call New_j_term()
        execute "sbuffer ".l:filename
    endif
    call chansend(t:termchannel, [a:command, ''])
endfunction

function! Debug_java()
    wa
    call Task(t:debugTask)
    let t:debugWait = 1
endfunction

let s:lines = ['']
function! Jdb_handler(channel, data, event)
    if t:debugWait
        if match(data[0], "5005") != -1
            JDebug
        endif
    endif
endfunction

let t:runTask = "gradle run -q"
let t:debugTask = "gradle run --debug-jvm -q"
let t:buildTask = "gradle build -q"
let t:testTask = "gradle test -q"
let t:installTask = "gradle installDebug -q"

let t:args = ""
let t:debugWait = 0
let t:srcDir = "*/src/main/java"

nnoremap <buffer><silent> <localleader>r :call Task(t:runTask)<Cr>
nnoremap <buffer><silent> <localleader>b  :let g:curPos = winsaveview()<Cr> :call Task(t:buildTask)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <localleader>t :let g:curPos = winsaveview()<Cr> :call Task(t:testTask)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <localleader>i :let g:curPos = winsaveview()<Cr> :call Task(t:installTask)<Cr> :call winrestview(g:curPos)<Cr>

if filereadable('.vProj.vim')
    source .vProj.vim
endif

cabbr <expr> %% t:srcDir
cabbr <expr> %& expand('%:h')
