" CapitalL Plugin: Easier quickfix and location lists
" Todo
"   - Lgreppattern and Cgreppattern vars that can be set in ftplugin
"   - put the default grep pattern in a plugin-specific ftplugin folder
"   - make keybindings customizable
"   - width should be a width or a height depending on position
"   - get filename for grepping from current window using ls
"   - grab current cursor position stuff from cenwin

"" Defaults
if !exists("g:CapitalL_width")
    let g:CapitalL_width = 40
endif
if !exists("g:CapitalL_position")
    let g:CapitalL_position = "left"
endif
if !exists("g:CapitalL_DefaultKeybindings")
    let g:CapitalL_DefaultKeybindings = 1
endif

"" Commands
command! Ltoggle execute ":call Ltoggle()"
command! Lopen execute ":call CapitalL_lopen()"
command! Lclose execute ":call CapitalL_lclose()"
command! Lvimgrep execute ":call CapitalL_lvimgrep()"
command! Lcycle execute ":call CapitalL_cycle()"

"" Keybindings
if g:CapitalL_DefaultKeybindings == 1
    nnoremap <localleader>l :Ltoggle<CR>
    nnoremap <localleader><localleader>l :Lcycle<CR>
    nnoremap <localleader>L :Lvimgrep<CR>
endif

"" Cycle between grep patterns
" - current pattern is indexed by b:CapitalL_pattern
" - it is an index of the list b:CapitalL_patterns
function! CapitalL_cycle()
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif
    let b:CapitalL_currentPattern += 1
    if b:CapitalL_currentPattern > len(b:CapitalL_patterns) - 1
        let b:CapitalL_currentPattern = 0
    endif
    execute ":call CapitalL_lvimgrep()"
    execute ":call CapitalL_lopen()"
endfunction

"" Grep to populate lists
" by default uses the values of patterns and currentPattern
" - todo: if an input is given, grep that, else grep like normal
function! CapitalL_lvimgrep()
    if !exists("b:CapitalL_patterns")
        echohl ErrorMsg
        echo "No CapitalL patterns are set for this buffer. Set b:CaptialL_patterns"
        return
    end
    " if we're in a loclist, get filename of associated file
    if exists("b:CapitalL_associatedFile")
        let filename = b:CapitalL_associatedfile
    else
        let filename = '%'
    endif
    execute "lvimgrep /".b:CapitalL_patterns[b:CapitalL_currentPattern]."/g ".filename
endfunction

"" Open the lists
function! CapitalL_lopen()
    let associatedFile = %
    let position = CapitalL_getPosition(g:CapitalL_position)
    execute position." lopen"
    "TODO make sure we're focused on the loclist window before adjusting it
    execute "vertical resize ".g:CapitalL_width
    let b:CapitalL_filename = associatedFile
    set modifiable
    silent %s/\v^([^|]*\|){2,2} //e
    setlocal nowrap
    set nomodified nomodifiable cursorline
    nnoremap <buffer> q :Lclose<CR>
    nnoremap <buffer> l <CR>zt
endfunction

" parse the position
function! CapitalL_getPosition(position)
    if a:position == "right"
        return "vertical"
    elseif a:position == "left"
        return "topleft vertical"
    elseif a:position == "top"
        return "topleft"
    elseif a:position == "bottom"
        return "botright"
    else
        return "topleft vertical"
    endif
endfunction

"" Closing the windows
function! CapitalL_lclose()
    execute "lclose"
endfunction

"" Functions for toggling the lists
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
function! CapitalL_GetBufferList()
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! CapitalL_ToggleList(bufname, pfx)
    let buflist = CapitalL_GetBufferList()
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        if bufwinnr(bufnum) != -1
          exec(a:pfx.'close')
          return
        endif
    endfor
    " call custom grep functions if list is empty
    if a:pfx == 'l' && len(getloclist(0)) == 0
        execute "call CapitalL_lvimgrep()"
    elseif a:pfx == 'c' && len(getqflist(0)) == 0
        execute "call CapitalL_cvimgrep()"
    endif
    let winnr = winnr()
    exec(toupper(a:pfx).'open')
    if winnr() != winnr
        wincmd p
    endif
endfunction

function! Ltoggle()
    execute "call CapitalL_ToggleList('Location List', 'l')"
endfunction
"function! Ctoggle()
"    execute "call CapitalL_ToggleList('Quickfix List', 'c')"
"endfunction

