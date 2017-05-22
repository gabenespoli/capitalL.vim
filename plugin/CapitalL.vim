"" CapitalL.vim: Easier location lists in vim.  

" notes
" - most of these functions start with Lclose and end with Lopen, 
"   so that buffer-specific variables are accessible if the 
"   current window is a loc list

"" Defaults
if !exists("g:CapitalL_defaultPosition")
    let g:CapitalL_defaultPosition = "left"
endif
if !exists("g:CapitalL_width")
    let g:CapitalL_defaultWidth = 40
endif
if !exists("g:CapitalL_enableKeybindings")
    let g:CapitalL_enableKeybindings = 1
endif

"" Commands
command! Ltoggle call CapitalL_toggle()
command! Lopen call CapitalL_lopen()
command! Lclose call CapitalL_lclose()
command! Lvimgrep call CapitalL_lvimgrep()
command! -nargs=1 Ladd call CapitalL_add(<f-args>)
command! Lshow call CapitalL_showPatterns()
command! Lnext call CapitalL_cycle(1)
command! Lprevious call CapitalL_cycle(-1)
command! -nargs=1 Lposition call CapitalL_setPosition(<f-args>)

"" Functions
function! CapitalL_lopen()
    execute ":call CapitalL_lclose()"
    "execute ":call CapitalL_lvimgrep()"

    "get buffer variables together before switching to loclist buffer
    if !exists("b:CapitalL_position")
        let b:CapitalL_position = g:CapitalL_defaultPosition
    endif
    if !exists("b:CapitalL_width")
        let b:CapitalL_width = g:CapitalL_defaultWidth
    endif
    let position = CapitalL_parsePosition(b:CapitalL_position)
    let width = b:CapitalL_width
    let associatedFile = expand('%:p')
    let filetype = &filetype

    execute position." lopen"

    "TODO make sure we're focused on the loclist window before adjusting it
    "if the position is vertical, format and resize 
    if position == "vertical" || position == "topleft vertical"
        execute "vertical resize ".width
        set modifiable
        silent %s/\v^([^|]*\|){2,2} //e
        execute "set syntax=".filetype
        set nomodified cursorline
    endif

    set cursorline
    setlocal nowrap

    let b:CapitalL_filename = associatedFile

    if g:CapitalL_enableKeybindings == 1
        nnoremap <buffer> q :Lclose<CR>
        nnoremap <buffer> l <CR>zt
        nnoremap <buffer> } :call CapitalL_cycle(1)<CR>
        nnoremap <buffer> { :call CapitalL_cycle(-1)<CR>
        nnoremap <buffer> ]] :call CapitalL_cycle(1)<CR>
        nnoremap <buffer> [[ :call CapitalL_cycle(-1)<CR>
        "keybindings for staying in loclist after doing something
        if position == "topleft vertical"
            nnoremap <buffer> J j<CR>zt<C-w>h
            nnoremap <buffer> K k<CR>zt<C-w>h
            nnoremap <buffer> o <CR>zt<C-w>h
        elseif position == "vertical"
            nnoremap <buffer> J j<CR>zt<C-w>l
            nnoremap <buffer> K k<CR>zt<C-w>l
            nnoremap <buffer> o <CR>zt<C-w>l
        elseif position == "topleft"
            nnoremap <buffer> J j<CR>zt<C-w>k
            nnoremap <buffer> K k<CR>zt<C-w>k
            nnoremap <buffer> o <CR>zt<C-w>k
        elseif position == "botright"
            nnoremap <buffer> J j<CR>zt<C-w>j
            nnoremap <buffer> K k<CR>zt<C-w>j
            nnoremap <buffer> o <CR>zt<C-w>j
        endif
    endif

    normal! gg
endfunction

function! CapitalL_setPosition(position)
    execute "call CapitalL_lclose()"
    let possible = ["left","right","top","bottom"]
    if index(possible,a:position) < 0
        echohl ErrorMsg
        echo "Position must be left, right, top, or bottom.
        return
    endif
    let b:CapitalL_position = a:position
    execute "call CapitalL_lopen()"
endfunction

function! CapitalL_parsePosition(position)
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

function! CapitalL_lclose()
    execute "lclose"
endfunction

function! CapitalL_GetBufferList()
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! CapitalL_toggle()
" modified from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
    let buflist = CapitalL_GetBufferList()
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "Location List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        if bufwinnr(bufnum) != -1
          exec('lclose')
          return
        endif
    endfor
    " call custom grep functions if list is empty
    if len(getloclist(0)) == 0
        execute "call CapitalL_lvimgrep()"
    endif
    let winnr = winnr()
    exec('Lopen')
    if winnr() != winnr
        wincmd p
    endif
endfunction

function! CapitalL_lvimgrep()
" by default uses the values of patterns and currentPattern
" - todo: if an input is given, grep that, else grep like normal

    execute ":call CapitalL_lclose()"

    if !exists("b:CapitalL_patterns")
        let b:CapitalL_patterns = ['TODO']
    endif
    " make sure it is a list variable
    if type(b:CapitalL_patterns) != 3
        let b:CapitalL_patterns = [b:CapitalL_patterns]
    end
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif
    " make sure current pattern ind doesn't exceed number of patterns
    if b:CapitalL_currentPattern < 0
        echohl ErrorMsg
        echo "CapitalL.vim: The current pattern index exceeds the number of patterns."
        return
    endif
    execute "silent! lvimgrep /".b:CapitalL_patterns[b:CapitalL_currentPattern]."/g %"
endfunction

function! CapitalL_showPatterns()
    execute "call CapitalL_lclose()"
    if !exists("b:CapitalL_patterns")
        echo "No CapitalL patterns are currently specified."
    else
        echo b:CapitalL_patterns
    endif
    execute "call CapitalL_lopen()"
endfunction

function! CapitalL_add(pattern)
    " add a new pattern to the list and change loc list to that pattern
    execute "call CapitalL_lclose()"
    if !exists("b:CapitalL_patterns")
        let b:CapitalL_patterns = [a:pattern]
    elseif type(b:CaptialL_patterns) == 3
        " if it's not a list, make it one before adding
        let b:CapitalL_patterns = b:CapitalL_patterns + [a:pattern]
    else
        let b:CapitalL_patterns = [b:CapitalL_patterns, a:pattern]
    endif
    " update current pattern to the new one
    let b:CapitalL_currentPattern = len(b:CapitalL_patterns) - 1
    execute "call CapitalL_lopen()"
endfunction

function! CapitalL_rm()
    execute "call CapitalL_lclose()"
    " remove the currently selected pattern from the patterns list
    execute "call remove(b:CapitalL_patterns, b:CapitalL_currentPattern)"
    " adjust the pattern index
    if b:CapitalL_currentPattern != 0
        let b:CapitalL_currentPattern = b:CapitalL_currentPattern - 1
    endif
    execute "call CapitalL_lopen()"
endfunction

function! CapitalL_cycle(...)
    execute ":call CapitalL_lclose()"
" - current pattern is indexed by b:CapitalL_pattern
" - it is an index of the list b:CapitalL_patterns
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif
    if !exists("b:CapitalL_patterns")
        let b:CapitalL_patterns = ['TODO']
    endif
    " make sure it is a list variable
    if type(b:CapitalL_patterns) != 3
        let b:CapitalL_patterns = [b:CapitalL_patterns]
    endif

    " If no input default cycle forwards
    if a:0 == 0
        let adj = 1
    else
        let adj = a:1
    endif

    "let startPattern = b:CapitalL_currentPattern
    "let stopCycle = 0
    "while stopCycle == 0
        "cycle the patterns
        let b:CapitalL_currentPattern = b:CapitalL_currentPattern + adj
        " wrap around if index will be out of range
        if b:CapitalL_currentPattern > len(b:CapitalL_patterns) - 1
            let b:CapitalL_currentPattern = 0
        endif
        if b:CapitalL_currentPattern < 0
            let b:CapitalL_currentPattern = len(b:CapitalL_patterns) - 1
        endif
    "endwhile

    execute ":call CapitalL_lopen()"
endfunction
