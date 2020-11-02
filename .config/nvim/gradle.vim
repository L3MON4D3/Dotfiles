function! Debug_java()
    wa
    call Exec_term(t:debugTask)
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

let t:runTask = "./gradlew run -q"
let t:debugTask = "./gradlew run --debug-jvm -q"
let t:buildTask = "./gradlew build -q"
let t:testTask = "./gradlew test -q"
let t:installTask = "./gradlew installDebug -q"
let t:cleanTask = "./gradlew clean -q"
let t:allTask = "./gradlew clean build -q"

let t:args = ""
let t:debugWait = 0
let t:srcDir = "*/src/main/java"
let t:mainDir = "*/src/main"
let t:layoutDir = "*/src/main/res/layout"

nnoremap <buffer><silent> <localleader>r :call Exec_term(t:runTask)<Cr>
nnoremap <buffer><silent> <localleader>b :let g:curPos = winsaveview()<Cr> :call Exec_term(t:buildTask)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <localleader>t :let g:curPos = winsaveview()<Cr> :call Exec_term(t:testTask)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <localleader>i :let g:curPos = winsaveview()<Cr> :call Exec_term(t:installTask)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <localleader>a :let g:curPos = winsaveview()<Cr> :call Exec_term(t:allTask)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <localleader>c :let g:curPos = winsaveview()<Cr> :call Exec_term(t:cleanTask)<Cr> :call winrestview(g:curPos)<Cr>

if filereadable('.vProj.vim')
    source .vProj.vim
endif

cabbr <expr> %% t:srcDir
cabbr <expr> %$ t:mainDir
cabbr <expr> $$ t:layoutDir

source ~/.config/nvim/coc.vim
