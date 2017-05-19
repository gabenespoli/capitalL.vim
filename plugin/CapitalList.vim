" CapitalList Plugin: Easier quickfix and location lists
" Todo
"   - Lgreppattern and Cgreppattern vars that can be set in ftplugin
"   - put the default grep pattern in a plugin-specific ftplugin folder
"   - make keybindings customizable

"" Defaults
if !exists("g:CapitalList_Lwidth")
    let g:CapitalList_Lwidth = 40
endif
if !exists("g:CapitalList_Cwidth")
    let g:CapitalList_Cwidth = 40
endif
if !exists("g:CapitalList_Lposition")
    let g:CapitalList_Lposition = "left"
endif
if !exists("g:CapitalList_Cposition")
    let g:CapitalList_Cposition = "right"
endif
if !exists("g:CapitalList_DefaultKeybindings")
    let g:CapitalList_DefaultKeybindings = 1
endif

"" Commands
command! Ltoggle execute ":call Ltoggle()"
command! Ctoggle execute ":call Ctoggle()"
command! Lopen execute ":call CapitalList_lopen()"
command! Copen execute ":call CapitalList_copen()"
command! Lclose execute ":call CapitalList_lclose()"
command! Cclose execute ":call CapitalList_cclose()"
command! Lvimgrep execute ":call CapitalList_lvimgrep()"
command! Cvimgrep execute ":call CapitalList_cvimgrep()"

"" Keybindings
if g:CapitalList_DefaultKeybindings == 1
    nnoremap <localleader>l :Ltoggle<CR>
    nnoremap <localleader>q :Ctoggle<CR>
    nnoremap <localleader>L :Lvimgrep<CR>
    nnoremap <localleader>Q :Cvimgrep<CR>
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
function! CapitalList_cvimgrep()
    if !exists("b:CapitalList_Cpattern")
        echohl ErrorMsg
        echo "No grep pattern set for this buffer. Set b:CaptialList_Cpattern"
        return
    else
        execute "vimgrep /".b:CapitalList_Cpattern."/g %"
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
    nnoremap <localleader>l :Lclose<CR>
endfunction
function! CapitalList_copen()
    let position = CapitalList_getPosition(g:CapitalList_Cposition)
    execute position." copen"
    execute "vertical resize ".g:CapitalList_Cwidth
    set modifiable
    silent %s/\v^([^|]*\|){2,2} //e
    setlocal nowrap
    set nomodified nomodifiable cursorline
    nnoremap <buffer> q :Cclose<CR>
    nnoremap <localleader>q :Cclose<CR>
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
    nnoremap <localleader>l :Lopen<CR>
endfunction
function! CapitalList_cclose()
    execute "cclose"
    nnoremap <localleader>q :Copen<CR>
endfunction

"" Functions for toggling the lists
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
function! GetBufferList()
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! ToggleList(bufname, pfx)
    let buflist = GetBufferList()
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        if bufwinnr(bufnum) != -1
          exec(a:pfx.'close')
          return
        endif
    endfor
    if a:pfx == 'l' && len(getloclist(0)) == 0
        execute "call CapitalList_lvimgrep()"
    endif
    let winnr = winnr()
    exec(toupper(a:pfx).'open')
    if winnr() != winnr
        wincmd p
    endif
endfunction

function! Ltoggle()
    execute "call ToggleList('Location List', 'l')"
endfunction
function! Ctoggle()
    execute "call ToggleList('Quickfix List', 'c')"
endfunction

