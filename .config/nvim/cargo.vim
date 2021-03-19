let t:execName=system("grep name Cargo.toml | perl -pe 's/name\\s=\\s\"(.*)\"\\n/$1/g'")
let t:run="cargo run"
let t:args=""
let t:runPost=""

set makeprg=cargo
set errorformat=
			\%-G,
            \%-Gerror:\ aborting\ %.%#,
            \%-Gerror:\ Could\ not\ compile\ %.%#,
            \%Eerror:\ %m,
            \%Eerror[E%n]:\ %m,
            \%Wwarning:\ %m,
            \%Inote:\ %m,
            \%C\ %#-->\ %f:%l:%c,
            \%E\ \ left:%m,%C\ right:%m\ %f:%l:%c,%Z

let t:srcDir = "src"

"autocmd BufRead *.rs :setlocal tags=./tags;/,$RUST_SRC_PATH/tags
"autocmd BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&" | redraw!

nnoremap <buffer><silent> <localleader>r :execute "!".t:run." ".t:args.";".t:runPost<Cr>
nnoremap <buffer><silent> <localleader>b :Make build<Cr>
nnoremap <buffer><silent> <localleader>c :Make check<Cr>
nnoremap <buffer><silent> <localleader>t :Make test<Cr>
nnoremap <buffer><silent> <localleader>e :e src/

cabbr <expr> %% t:srcDir
cabbr <expr> %m t:srcDir."/main.rs"

if filereadable('.vProj.vim')
    source .vProj.vim
endif
