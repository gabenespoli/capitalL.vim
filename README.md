# CapitalL: Easier location lists in vim.

The vim Location List is a buffer containing links to certain lines of file which match a pattern. It can be populated using `lvimgrep` and a regex pattern, and opened using `lopen`. CapitalL is a vim plugin which stores multiple patterns in a variable, so that you can cycle through different patterns easily. For instance, one pattern could be lines beginning with two comment characters (e.g., `""` in vim, `##` in bash/python, `%%` in octave/matlab), and another could be lines beginning with a function definition (e.g., `function` in vim/octave/matlab, `class` and `def` in python). It can also be used to list TODOs present in a file.

The Location List is specified as the same filetype as the file so that it inherits the same syntax highlighting. This is only apparent when the Location List is positioned on the left or right, when CapitalL reformats the list (i.e., strips the filename and line/col number information).

![CapitalL.vim. Search pattern is ^\"\"](http://i.imgur.com/nAOs0em.png)

![CapitalL.vim. Search pattern is ^function](http://i.imgur.com/B4o7yFi.png)

## Installation

Vundle `Plugin 'gabenespoli/CapitalL.vim'`

## Commands

`Lopen` = Open the Location List buffer. If it is on the left or right, reformat it. This runs `Lvimgrep` first to make sure the Location List is updated and for the current file.

`Lclose` = Close the Location List buffer.

`Ltoggle` = Toggle whether the Location List is open or closed.

`Lvimgrep` = Populate the Location List by using `lvimgrep` and the string present in `b:CapitalL_patterns[b:CapitalL_currentPattern]`.

`Lnext` = Populate the Location List with the next pattern in `b:CaptitalL_patterns`. This will keep cycling through patterns until either the Location List is non-empty, or it has tried all of the patterns.

`Lprevious` = Same as `Lnext`, but cycles through patterns in the opposite direction.

`Ladd <pattern>` = Add a pattern to the list. This is useful for "on-the-fly" location lists, instead of adding a pattern to the ftplugin file.

`Lposition <position>` = Change the position of the Location List for the current buffer. Can be 'left', 'right', 'top', or 'bottom'.

`Lrefresh` = Reformats all lists to have the appropriate position, width, and text formatting. When called with the argument `l`, it also runs `Lvimgrep`.

## Keybindings

There are no global keybindings enabled by default. Consider adding the following keybindings to your vimrc.

```
nnoremap <localleader>l :Ltoggle<CR>
nnoremap <localleader>q :Ctoggle<CR>
nnoremap <localleader>L :Lrefresh<CR>
```

### Keybindings in the Location List and Quickfix Windows

These keybindings are on by default, and can be turned off by adding `g:CapitalL_enableKeybindings = 0` to your vimrc.

`q` = Close the List (`Lclose` or `Cclose`).

`r` = Refresh the formatting of all lists (`Lrefresh`). If the cursor is focused in a Location List, also redo `Lvimgrep`.

`l` = Go to the currently selected line in the associated file, and put that line at the top of the screen.

`o` = Same as `l` except keep move the cursor back to Location List.

`J` and `K` = Go to the next or previous item in the list, open it, and move focus back to the list. It's like typing `jo` or `ko`.

These keybindings are available in the Location List (not the Quickfix List).

`}` or `]]` = Cycle to the next pattern (`Lnext`).

`{` or `[[` = Cycle to the previous pattern (`Lprevious`).

## Global Variables

These variables can be set in your vimrc if you don't want the defaults.

`g:CapitalL_defaultPosition` = The default position of the Location List. Can be `'left'`, `'right'`, `'top'`, or `'bottom'`. Default `'left'`.

`g:CapitalL_defaultWidth` = The default width of a Location List positioned on the left or right. Default 40.

`g:CapitalL_defaultPattern` = This defaults to `['TODO']`

`g:CapitalL_enableKeybindings` = Enter 1 or 0 to enable or disable the default keybindings in the Location List buffer. Default 1.

## Buffer-Specific Variables

These variables can be set in a file in the `ftplugin` folder. `b:CapitalL_patterns` is required for this plugin to do anything.

`b:CapitalL_position` = The position of the Location List associated with the buffer. Defaults to `g:CapitalL_defaultPosition`.

`b:CapitalL_width` = The width of the Location List associated with the buffer if it is on the left or right. Defaults to `g:CapitalL_defaultWidth`.

`b:CapitalL_patterns` = A list of patterns to use with `lvimgrep` to create the location lists. The defaults can be found in the `ftplugin` folder of this repository. The default if no ftplugin file is found is `['TODO']'`.

`b:CaptialL_currentPattern` = An index specifying which pattern in `b:CapitalL_patterns` is being used for this buffer's Location List.

## Special Markdown Formatting

If the filetype is markdown or pandoc, then the Location List is formatted differently. The #'s for headings are replaced with 2 spaces each (except for level 1). Each heading is given the syntax LmarkdownH1, LmarkdownH2, etc., and the highlights are linked to markdownH1, markdownH2, etc. This indented format that removes the leading #'s is easier to read and see the outline of the document. The syntax highlighting for markdown headings is retained, but also customizable, if for example you wanted to see level 1 headings with a different background.

## Analogous Quickfix Window Functionality

There are analogous functions `Copen`, `Cclose`, `Ctoggle`, and associated variables `g:CapitalL_qf_position` and `g:CapitalL_qf_width`. For controlling the quickfix window.

## TODO


- Allow for multiple inputs into Ladd and combine them with logical or: `\(pattern1\|pattern2\)`

- implement a function to change the special formatting of the list to the markdown version. Implement a pseudo-markdown-headings formatting that can use any comment character, but the first heading level is ignored (i.e., in vim, `""` is a level 1 heading, `"""` is a level 2 heading, etc., and `"` are ignored). This allows relatively easy implementation of some document structure to code files.
