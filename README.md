# IndentWise

## Description

`IndentWise` is a Vim plugin that provides for the following movements based on indent levels:

- `[-`  : Move to *previous* line of *lesser* indent as the current line
- `]-`  : Move to *next* line of *lesser* indent as the current line
- `[+`  : Move to *previous* line of *greater* indent as the current line
- `]+`  : Move to *next* line of *greater* indent as the current line
- `[=`  : Move to *previous* line of *same* indent as the current line
- `]=`  : Move to *next* line of *same* indent as the current line

## Installation

### [pathogen.vim](https://github.com/tpope/vim-pathogen)

    $ cd ~/.vim/bundle
    $ git clone git://github.com/jeetsukumaran/vim-indentwise.git


### [Vundle](https://github.com/gmarik/vundle.git)

    :BundleInstall jeetsukumaran/vim-indentwise

Add the line below into your _.vimrc_.

    Bundle 'jeetsukumaran/vim-indentwise'

### Manually

Copy the _plugin/indentwise.vim_ file to your _.vim/plugin_ directory and the
_doc/indentwise.txt_ file to your _.vim/doc_ directory and the _plugin_
sub-directories to your _.vim_ directory.


## Acknowledgements

IndentWise is based on the following:

-   ["Move to next/previous line with the same indentation"](http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation)
