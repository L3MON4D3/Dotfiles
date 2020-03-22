function! MyFoldText()
    return substitute(getline(v:foldstart), "\\s\\{4\\}\\S.*", "|", "")
endfunction

function! SwitchImplemetationInterface()
    if expand('%:e') == "hpp"
        exec "edit " . substitute(expand('%'), '\.hpp', '\.cpp', '')
    else 
        if expand('%:e') == "cpp"
            exec "edit " . substitute(expand('%'), '\.cpp', '\.hpp', '')
        endif
    endif
endfunction

function! MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        let s .= ' %{MyTabLabel('.(i+1).')}%{g:branches['.(i).']} '
    endfor

    "let s .= '%#Statusbg#%T'
    let s .= '%=%{w:fpRel}'

    return s
endfunction

function! MyTabLabel(n)
    return fnamemodify(getcwd(-1, a:n), ":~")
endfunction

function! AddSpacesNonempty(string)
    if a:string != ""
        return "\ ".a:string."\ "
    endif
    return ""
endfunction

function! FilenameClean()
    if mode()=='t'
        return 'Bash'
    endif
    let l:fn=expand('%:t')
    if l:fn==''
        return ''
    endif
    return l:fn
endfunction

function! FilepathClean()
    if mode()=='t'
        return ''
    endif
    let l:fp=expand('%:.:h')
    if l:fp==''
        return ''
    endif
    return l:fp
endfunction

function! FiletypeClean()
    if mode()=='t'
        return ' Terminal '
    endif
    let l:ft=&filetype
    if l:ft==''
        return ''
    endif
    return ' '.l:ft.' '
endfunction

function! BranchClean()
    let l:branches=[]
    for i in range(tabpagenr('$'))
        let l:branch = [system("cd ". getcwd(-1,i+1) ." && git branch --show-current")[:-2]]
        if match(l:branch[0], "^fatal:") == 0
            let l:branch = [""]
        else
            let l:branch[0]=": ".l:branch[0]
        endif
        let l:branches+=l:branch
    endfor
    return l:branches
endfunction

function! VarExists(var)
    if exists(a:var) | return a:var | else | return '' | endif
endfunction

function! Statusline()
    let l:var = "%#Status1#"."%( %{w:stFn}%m %)"
    let l:var .= "%#Status2#"."%{w:stFt}"
    let l:var .= "%1*"
    let l:var .= "%="
    let l:var .= "%#Status_1#\ %03l/%L:%02c\ "
    return l:var
endfunction
