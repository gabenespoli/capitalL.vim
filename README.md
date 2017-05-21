# CapitalL: Easier location lists in vim.

The vim Location List is a buffer containing links to certain lines of file which match a pattern. It can be populated using `lvimgrep` and a regex pattern, and opened using `lopen`. CapitalL is a vim plugin which stores multiple patterns in a variable, so that you can cycle through different patterns easily. For instance, one pattern could be lines beginning with two comment characters (e.g., `""` in vim), and another could be lines beginning with a function definition (e.g., `function` in vim).

The Location List is specified as the same filetype as the file, and so it inherits the same syntax highlighting. This is only apparent when the Location List is positioned on the left or right, when CapitalL reformats the list (i.e., strips the filename and line/col number information).

![CapitalL.vim. Search pattern is ^\"\"](http://i.imgur.com/nAOs0em.png)

![CapitalL.vim. Search pattern is ^function](http://i.imgur.com/B4o7yFi.png)

## Installation

Vundle `Plugin 'gabenespoli/CapitalL.vim'`

## Commands

`Ltoggle` = Toggle whether the Location List is open or closed. I set this to `<localleader>l` in my vimrc.

`Lopen` = Open the Location List buffer. If it is on the left or right, reformat it.

`Lclose` = Close the Location List buffer.

`Lvimgrep` = Populate the Location List by using `lvimgrep` and the string present in `b:CapitalL_patterns[b:CapitalL_currentPattern]`.

`Lnext` = Populate the Location List with the next pattern in `b:CaptitalL_patterns`. This will keep cycling through patterns until either the Location List is non-empty, or it has tried all of the patterns.

`Lprevious` = Same as `Lnext`, but cycles through patterns in the opposite direction.

## Keybindings in the Location List Window

These keybindings are available in the Location List window only. They can be enabled or disabled with the `g:CapitalL_enableKeybindings` variable.

`q` = Close the Location List (`Lclose`)

`l` = Go to the currently selected line in the associated file, and put that line at the top of the screen.

`o` = Same as `l` except keep the cursor in the Location List.

`J` and `K` = Go to the next item in the list, open it, and move focus back to the list. It's like typing `jo` or `ko`.

`}` and `]]` = Cycle to the next pattern (`Lnext`).

`{` and `[[` = Cycle to the previous pattern (`Lprevious`).

## Global Variables

These variables can be set in your vimrc if you don't want the defaults.

`g:CapitalL_defaultPosition` = The default position of the Location List. Can be `'left'`, `'right'`, `'top'`, or `'bottom'`. Default `'left'`.

`g:CapitalL_defaultWidth` = The default width of a Location List positioned on the left or right. Default 40.

`g:CapitalL_enableKeybindings` = Enter 1 or 0 to enable or disable the default keybindings in the Location List buffer. Default 1.

## Buffer-Specific Variables

These variables can be set in a file in the `ftplugin` folder. `b:CapitalL_patterns` is required for this plugin to do anything.

`b:CapitalL_position` = The position of the Location List associated with the buffer. Defaults to `g:CapitalL_defaultPosition`.

`b:CapitalL_width` = The width of the Location List associated with the buffer if it is on the left or right. Defaults to `g:CapitalL_defaultWidth`.

`b:CapitalL_patterns` = A list of patterns to use with `lvimgrep` to create the location lists. The defaults can be found in the `ftplugin` folder of this repository. The default if no ftplugin file is found is `['TODO']'`.

`b:CaptialL_currentPattern` = An index specifying which pattern in `b:CapitalL_patterns` is being used for this buffer's Location List.

## TODO

- Add command `Ladd` to easily add a pattern to the current `b:CapitalL_patterns` variable. Currently you have to do something like `:let b:CaptialL_patterns = b:CapitalL_patterns + ['newpattern']`. It would be better to do `:Ladd newpattern`.

- Add command `Lposition` to easily change the position. E.g., `:Lpos bottom`

- Add special formatting of Location List for markdown files (replace #'s with indent, use default markdown heading formatting).

