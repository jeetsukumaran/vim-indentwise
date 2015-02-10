# IndentWise

## Description

`IndentWise` is a Vim plugin that provides for motions based on indent depths
or levels in normal, visual, and operator-pending modes.

### Movements by Relative Indent-Depth

The following key-mappings provide motions to go to lines of lesser, equal, or
greater indent than the line that the cursor is currently on:

- `[-`  : Move to *previous* line of *lesser* indent than the current line.
- `[+`  : Move to *previous* line of *greater* indent than the current line.
- `[=`  : Move to *previous* line of *same* indent as the current line that
          is separated from the current line by lines of different indents.
- `]-`  : Move to *next* line of *lesser* indent than the current line.
- `]+`  : Move to *next* line of *greater* indent than the current line.
- `]=`  : Move to *next* line of *same* indent as the current line that
          is separated from the current line by lines of different indents.

The above all take a `{count}`, so that, e.g., ``4[-`` will move to the
previous line that is 4 indent-depths less than the current one. An
"indent-depth" is simply the indentation of the line, and thus any line with a
smaller amount of indentation relative to current line is considered at a
lesser indent depth, and, conversely, any line with a greater indentation than
the current line is considered to be at a greater indent-depth.

### Movements by Absolute Indent-Levels

In addition, you can navigate directly to a line of a particular
indent-*level*, with the level specified by a (mandatory)
`{count}` directive, using:

- `{count}[_`  : Move to *previous* line with indent-level of `{count}`.
- `{count}]_`  : Move to *next* line with indent-level of `{count}`.

An "indent-*level*" of a line is the number of ``shiftwidth`` units that the
line is indented (as opposed to the "indent-*depth*", which is just the
indentation amount of a line).

### Movements by Indent-Block Scope

The following key-mappings provide motions based on indent-block scope
boundaries, with an optional `{count}` directive specifying the number
of levels of scope to include:

- `[%`  : Move to beginning of indent-block scope (i.e., move to the
          line just after the previous line of lesser indent); repeat
          for `{count}` outer scopes.
- `]%`  : Move to end of indent-block scope (i.e., move to the line
          just before the next line of lesser indent); repeat
          for `{count}` outer scopes.

### Customization

If you are unhappy with the default key-mappings you can provide your own by
defining custom mappings in your _`.vimrc`_. For example to replicate the
default mappings, you would define the following:

    map [- <Plug>(IndentWisePreviousLesserIndent)
    map [= <Plug>(IndentWisePreviousEqualIndent)
    map [+ <Plug>(IndentWisePreviousGreaterIndent)
    map ]- <Plug>(IndentWiseNextLesserIndent)
    map ]= <Plug>(IndentWiseNextEqualIndent)
    map ]+ <Plug>(IndentWiseNextGreaterIndent)
    map [_ <Plug>(IndentWisePreviousAbsoluteIndent)
    map ]_ <Plug>(IndentWiseNextAbsoluteIndent)
    map [% <Plug>(IndentWiseBlockScopeBoundaryBegin)
    map ]% <Plug>(IndentWiseBlockScopeBoundaryEnd)

## Installation

### [pathogen.vim](https://github.com/tpope/vim-pathogen)

    $ cd ~/.vim/bundle
    $ git clone git://github.com/jeetsukumaran/vim-indentwise.git


### [Vundle](https://github.com/gmarik/vundle.git)

    :BundleInstall jeetsukumaran/vim-indentwise

Add the line below into your _.vimrc_.

    Bundle 'jeetsukumaran/vim-indentwise'

### Manually

Copy the _`plugin/indentwise.vim`_ file to your _`.vim/plugin`_ directory and the
_`doc/indentwise.txt`_ file to your _`.vim/doc`_ directory.

## Acknowledgements

IndentWise is based on the following:

-   ["Move to next/previous line with the same indentation"](http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation)
