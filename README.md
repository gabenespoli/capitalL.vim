# CapitalL: Easier location lists in vim.

CapitalL is basically a wrapper for the Location List commands in vim (`lvimgrep`, `lopen`, and `lclose`). The corresponding CapitalL functions using an uppercase `L` instead, hence the name. It cycles through a list of patterns to use for `lvimgrep` and displays matches in the location list. The position and size of the list can be specified with global defaults and/or buffer-specific variables. If the list is positioned on the left or right, the filename and line number information are removed to make the list more readable.

## Installation

Vundle: `Plugin 'gabenespoli/CapitalL.vim'`

## Commands

`Lvimgrep`

`Lopen`

`Lclose`

`Ltoggle`

`Lcycle`

## Keybindings

The default keybindings are (`<localleader>` is usually backslash).

`nnoremap <localleader>l :Ltoggle<CR>`

`nnoremap <localleader>L :Lcycle<CR>`

Add `let g:CapitalL_DefaultKeybindings = 1` to your vimrc to use the default keybindings.

## Global Variables

`g:CapitalL_defaultPosition` The default position of the Location List. Can be `'left'`, `'right'`, `'top'`, or `'bottom'`. Default `'left'`.

`g:CapitalL_defaultWidth` The default width of a Location List positioned on the left or right. Default 40.

`g:CapitalL_defaultKeybindings` Enter 1 to use the default keybindings. Default 0.

## Buffer-Specific Variables

`b:CapitalL_position` The position of the Location List associated with the buffer. Defaults to `g:CapitalL_defaultPosition`.

`b:CapitalL_width` The width of the Location List associated with the buffer if it is on the left or right. Defaults to `g:CapitalL_defaultWidth`.

`b:CapitalL_patterns` A list of patterns to use with `lvimgrep` to create the location lists. By default this is set in the relevant ftplugin file. For example, the default for vim files is `['^\"\"', '^\s*function', 'TODO']`.

`b:CaptialL_currentPattern` An index specifying which pattern in `b:CapitalL_patterns` is being used for this buffer's Location List.

# TODO

- add special formatting of Location List for markdown files (replace #'s with indent, use default markdown heading formatting)

