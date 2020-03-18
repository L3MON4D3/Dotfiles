if filereadable('build.gradle')
    source /home/simon/.vim/gradle.vim
else
    source /home/simon/.vim/cmake.vim
endif

function! DetermineFoldMethod()
    "gets all lines of current buffer in List.
    let lines = getline(1, '$')
    setlocal foldmethod=indent
    setlocal foldignore="*"
    if match(lines, '\v^(class|namespace).*') != -1
        setlocal foldnestmax=2
        setlocal foldlevel=1
    else
        setlocal foldnestmax=1
        setlocal foldlevel=0
    endif
endfunction

setlocal foldtext=MyFoldText()
setlocal fillchars=fold:\ ,vert:\|

call DetermineFoldMethod()
nnoremap <buffer> <localleader>ec :tabe ~/.vim/cpp.vim<Cr> :tc<Cr>
nnoremap <buffer> <localleader>sc :so ~/.vim/cpp.vim<Cr>
nnoremap <buffer> <localleader>i :call SwitchImplemetationInterface()<Cr>
nnoremap <buffer> <leader>c :let g:curPos = getcurpos()<Cr> I//<Esc> :call cursor(g:curPos[1:])<Cr>
