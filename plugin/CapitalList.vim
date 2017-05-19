" CapitalList Plugin: Easier quickfix and location lists
" Todo
"   - Lgreppattern and Cgreppattern vars that can be set in ftplugin
"   - put the default grep pattern in a plugin-specific ftplugin folder
"   - make keybindings customizable
"   - width should be a width or a height depending on position
"   - get filename for grepping from current window using ls
"   - grab current cursor position stuff from cenwin

"" Defaults
if !exists("g:CapitalList_Lwidth")
    let g:CapitalList_Lwidth = 40
endif
if !exists("g:CapitalList_Lposition")
    let g:CapitalList_Lposition = "left"
endif
if !exists("g:CapitalList_DefaultKeybindings")
    let g:CapitalList_DefaultKeybindings = 1
endif

"" Commands
command! Ltoggle execute ":call Ltoggle()"
command! Lopen execute ":call CapitalList_lopen()"
command! Lclose execute ":call CapitalList_lclose()"
command! Lvimgrep execute ":call CapitalList_lvimgrep()"

"" Keybindings
if g:CapitalList_DefaultKeybindings == 1
    nnoremap <localleader>l :Ltoggle<CR>
    nnoremap <localleader>L :Lvimgrep<CR>
endif

"" Grep to populate lists
function! CapitalList_lvimgrep()
    if !exists("b:CapitalList_Lpattern")
        echohl ErrorMsg
        echo "No grep pattern set for this buffer. Set b:CaptialList_Lpattern"
        return
    else
        execute "lvimgrep /".b:CapitalList_Lpattern."/g %"
    endif
endfunction

"" Open the lists
function! CapitalList_lopen()
    let position = CapitalList_getPosition(g:CapitalList_Lposition)
    execute position." lopen"
    execute "vertical resize ".g:CapitalList_Lwidth
    set modifiable
    silent %s/\v^([^|]*\|){2,2} //e
    setlocal nowrap
    set nomodified nomodifiable cursorline
    nnoremap <buffer> q :Lclose<CR>
    nnoremap <buffer> l <CR>zt
endfunction

" parse the position
function! CapitalList_getPosition(position)
    if a:position == "right"
        return "vertical"
    elseif a:position == "left"
        return "topleft vertical"
    elseif a:position == "top"
        return "topleft"
    elseif a:position == "bottom"
        return "botright"
    else
        return "vertical"
    endif
endfunction

"" Closing the windows
function! CapitalList_lclose()
    execute "lclose"
endfunction

"" Functions for toggling the lists
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
function! CapitalList_GetBufferList()
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! CapitalList_ToggleList(bufname, pfx)
    let buflist = CapitalList_GetBufferList()
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        if bufwinnr(bufnum) != -1
          exec(a:pfx.'close')
          return
        endif
    endfor
    " call custom grep functions if list is empty
    if a:pfx == 'l' && len(getloclist(0)) == 0
        execute "call CapitalList_lvimgrep()"
    elseif a:pfx == 'c' && len(getqflist(0)) == 0
        execute "call CapitalList_cvimgrep()"
    endif
    let winnr = winnr()
    exec(toupper(a:pfx).'open')
    if winnr() != winnr
        wincmd p
    endif
endfunction

function! Ltoggle()
    execute "call CapitalList_ToggleList('Location List', 'l')"
endfunction
"function! Ctoggle()
"    execute "call CapitalList_ToggleList('Quickfix List', 'c')"
"endfunction

