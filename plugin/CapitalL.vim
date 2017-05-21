"" CapitalL.vim: Easier location lists in vim.  

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
command! -nargs=1 Lpos let b:CapitalL_position = <f-args>

"" CapitalL_lopen()
function! CapitalL_lopen()
    execute "call CapitalL_lvimgrep()"

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
    if position == "topleft vertical" || position == "vertical"
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

"" CapitalL_parsePosition(position)
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

function! CapitalL_toggle()
    execute "call CapitalL_ToggleList('Location List', 'l')"
endfunction

function! CapitalL_GetBufferList()
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! CapitalL_ToggleList(bufname, pfx)
" modified from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
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

function! CapitalL_lvimgrep()
" by default uses the values of patterns and currentPattern
" - todo: if an input is given, grep that, else grep like normal
    if !exists("b:CapitalL_patterns")
        let b:CapitalL_patterns = ['TODO']
        "echohl ErrorMsg
        "echo "No CapitalL patterns are set for this buffer. Set b:CaptialL_patterns"
        "return
    end
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif
    " if we're in a loclist, get filename of associated file
    if exists("b:CapitalL_associatedFile")
        let filename = b:CapitalL_associatedfile
    else
        let filename = '%'
    endif
    execute "silent! lvimgrep /".b:CapitalL_patterns[b:CapitalL_currentPattern]."/g ".filename
endfunction

function! CapitalL_add(pattern)
    if !exists("b:CapitalL_patterns")
        let b:CapitalL_patterns = []
    endif
    let b:CapitalL_patterns = b:CapitalL_patterns + [a:pattern]
endfunction

function! CapitalL_showPatterns()
    if !exists("b:CapitalL_patterns")
        echo No CapitalL patterns are currently specified.
    else
        echo b:CapitalL_patterns
    endif
endfunction

function! CapitalL_cycle(...)
" - current pattern is indexed by b:CapitalL_pattern
" - it is an index of the list b:CapitalL_patterns
    execute ":call CapitalL_lclose()"
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif

    if a:0 == 0
        let adj = 1
    else
        let adj = a:1
    endif

    let startPattern = b:CapitalL_currentPattern
    let stopCycle = 0
    while stopCycle == 0
        "cycle to the next grep pattern
        let b:CapitalL_currentPattern = b:CapitalL_currentPattern + adj
        if b:CapitalL_currentPattern > len(b:CapitalL_patterns) - 1
            let b:CapitalL_currentPattern = 0
        endif
        if b:CapitalL_currentPattern < 0
            let b:CapitalL_currentPattern = len(b:CapitalL_patterns) - 1
        endif

        "do the grep
        execute ":call CapitalL_lvimgrep()"

        "exit if grep returns something
        if len(getloclist(0)) > 0
            let stopCycle = 1
        endif

        "exit if we've tried all the possible patterns
        if b:CapitalL_currentPattern == startPattern
            let stopCycle = 1
        endif
    endwhile
    execute ":call CapitalL_lopen()"
endfunction
