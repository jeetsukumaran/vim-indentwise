""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""  IndentWise
""
""  Indent-level based movements in Vim.
""
""  Copyright 2015 Jeet Sukumaran.
""
""  This program is free software; you can redistribute it and/or modify
""  it under the terms of the GNU General Public License as published by
""  the Free Software Foundation; either version 3 of the License, or
""  (at your option) any later version.
""
""  This program is distributed in the hope that it will be useful,
""  but WITHOUT ANY WARRANTY; without even the implied warranty of
""  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
""  GNU General Public License <http://www.gnu.org/licenses/>
""  for more details.
""
""  This program contains code from the following sources:
""
""  - Vim Wiki tip contributed by Ingo Karkat:
""
""          http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
""
""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Reload and Compatibility Guard {{{1
" ============================================================================
" Reload protection.
if (exists('g:did_indentwise') && g:did_indentwise) || &cp || version < 700
    finish
endif
let g:did_indentwise = 1
" avoid line continuation issues (see ':help user_41.txt')
let s:save_cpo = &cpo
set cpo&vim
" 1}}}

" Global Options {{{1
" ============================================================================
let g:indentwise_equal_indent_skips_contiguous = get(g:, 'indentwise_equal_indent_skips_contiguous', 1)
" 1}}}

" Support Code {{{1
" ==============================================================================

" sw() {{{2
" ==============================================================================
if exists('*shiftwidth')
    func s:sw()
        return shiftwidth()
    endfunc
else
    func s:sw()
        return &sw
    endfunc
endif
" 2}}}

" _get_line_of_relative_indent {{{2
" ==============================================================================
" Jump to the next or previous line that has the same depth, higher, or a
" lower depth of indentation than the current line.
"
" Shamelessly taken and modified from code contributed by Ingo Karkat:
"
"   http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
"
" Parameters
" ----------
" first_line_of_current_range,
" last_line_of_current_range : int
"   start and end lines of current line range
" fwd : bool
"   true: Go to next line; false: Go to previous line
" target_indent_depth : str
"   "<": Go to line with smaller indentation depth;
"   "==": Go to line with the same indentation depth;
"   ">": Go to line with the larger indentation depth;
"   ">=": Go to line with the greater than or equal indentation depth;
"   "<=": Go to line with the lesser than or equal indentation depth;
" reference_indent : int
"   If < 0, then the indent of the current line will be used; otherwise this
"   is the reference value for the indent of which we are seeking an lesser,
"   equal or greater indent.
" exclusive : bool
"   true: Motion is exclusive; false: Motion is inclusive
function! s:_get_line_of_relative_indent(first_line_of_current_range, last_line_of_current_range, fwd, target_indent_depth, reference_indent, exclusive, count)
    let stepvalue = a:fwd ? 1 : -1

    let skip_blanks = get(b:, "indentwise_skip_blanks", get(g:, "indentwise_skip_blanks", 1))
    let blanks_have_null_indentation = get(b:, "indentwise_blanks_have_null_indentation", get(g:, "indentwise_blanks_have_null_indentation", 1))
    let treat_whitespace_as_blank = get(b:, "indentwise_treat_whitespace_as_blank", get(g:, "indentwise_treat_whitespace_as_blank", 1))

    if a:fwd
        let stepvalue = 1
        let current_line = a:last_line_of_current_range
    else
        let stepvalue = -1
        let current_line = a:first_line_of_current_range
    endif
    let start_line = current_line
    let last_accepted_line = current_line
    let last_line_of_buffer = line('$')
    let current_indent = indent(current_line)
    let indent_depth_changed = 0
    let num_reps = a:count
    while (current_line > 0 && current_line <= last_line_of_buffer && num_reps > 0)
        let current_line = current_line + stepvalue
        let candidate_line_indent = indent(current_line)
        let accept_line = 0

        if treat_whitespace_as_blank
          let blank_line = empty(matchstr(getline(current_line), '[^\s]'))
        else
          let blank_line = empty(getline(current_line))
        endif

        if blank_line && blanks_have_null_indentation
          let indent_depth_changed = 1
        elseif ((a:target_indent_depth == "<") && candidate_line_indent < current_indent)
            let accept_line = 1
        elseif ((a:target_indent_depth == ">") && candidate_line_indent > current_indent)
            let accept_line = 1
        elseif (a:target_indent_depth == "==")
            if candidate_line_indent == current_indent
                if !skip_blanks || !blank_line
                  if l:indent_depth_changed || !g:indentwise_equal_indent_skips_contiguous
                      let accept_line = 1
                      let indent_depth_changed = 0
                  else
                      let last_accepted_line = current_line
                  endif
                endif
            elseif candidate_line_indent != current_indent
                let indent_depth_changed = 1
            endif
        endif
        if accept_line
            if !skip_blanks || !blank_line
                let num_reps = num_reps - 1
                let current_indent = candidate_line_indent
                let last_accepted_line = current_line
            endif
        endif
    endwhile
    if last_accepted_line == start_line
        return -1
    else
        if (a:exclusive)
            let last_accepted_line = last_accepted_line - stepvalue
        endif
        return last_accepted_line
    endif
endfunction
" }}}2

" _get_line_of_absolute_indent {{{2
" ==============================================================================
function! <SID>_get_line_of_absolute_indent(fwd, exclusive) range
    if a:fwd
        let stepvalue = 1
        let current_line = a:lastline
    else
        let stepvalue = -1
        let current_line = a:firstline
    endif
    let skip_blanks = get(b:, "indentwise_skip_blanks", get(g:, "indentwise_skip_blanks", 1))
    let lastline = line('$')
    let current_indent = indent(current_line)
    let target_indent = v:count * s:sw()
    let num_reps = 1
    while (current_line > 0 && current_line <= lastline && num_reps > 0)
        let current_line = current_line + stepvalue
        let candidate_line_indent = indent(current_line)
        if (candidate_line_indent == target_indent)
            if (! skip_blanks || strlen(getline(current_line)) > 0)
                let num_reps = num_reps - 1
                let current_indent = candidate_line_indent
            endif
        endif
    endwhile
    if (a:exclusive)
        let current_line = current_line - stepvalue
    endif
    if (current_line > 0 && current_line <= lastline)
        return current_line
    else
        return -1
    endif
endfunction
" 2}}}

" 1}}}

" Main Code {{{1
" ==============================================================================

" move_to_indent_depth {{{2
" ==============================================================================
" Jump to the next or previous line that has the same depth, higher, or a
" lower depth of indentation than the current line.
"
" Shamelessly taken and modified from code contributed by Ingo Karkat:
"
"   http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
"
" Parameters
" ----------
" exclusive : bool
"   true: Motion is exclusive; false: Motion is inclusive
" fwd : bool
"   true: Go to next line; false: Go to previous line
" target_indent_depth : str
"   "<": Go to line with smaller indentation depth;
"   "==": Go to line with the same indentation depth;
"   ">": Go to line with the larger indentation depth;
"   ">=": Go to line with the greater than or equal indentation depth;
"   "<=": Go to line with the lesser than or equal indentation depth;
function! <SID>move_to_indent_depth(fwd, target_indent_depth, exclusive, vim_mode) range
    let current_column = col('.')
    let target_line = s:_get_line_of_relative_indent(a:firstline, a:lastline, a:fwd, a:target_indent_depth, -1, a:exclusive, v:count1)
    if a:vim_mode == "v"
        normal! gv
    endif
    if target_line > 0
        let preserve_col_pos = get(b:, "indentwise_preserve_col_pos", get(g:, "indentwise_preserve_col_pos", 0))
        if preserve_col_pos
            execute "normal! " . target_line . "G" . current_column . "|"
        else
            execute "normal! " . target_line . "G^"
        endif
    endif
endfunction
" 2}}}

" move_to_absolute_indent_level {{{2
" ==============================================================================
function! <SID>move_to_absolute_indent_level(fwd, exclusive, vim_mode) range
    let current_column = col('.')
    let target_line = s:_get_line_of_absolute_indent(a:fwd, a:exclusive)
    if a:vim_mode == "v"
        normal! gv
    endif
    if target_line > 0
        let preserve_col_pos = get(b:, "indentwise_preserve_col_pos", get(g:, "indentwise_preserve_col_pos", 0))
        if preserve_col_pos
            execute "normal! " . target_line . "G" . current_column . "|"
        else
            execute "normal! " . target_line . "G^"
        endif
    endif
endfunction
" 2}}}

" move_to_indent_block_scope_boundary {{{2
" ==============================================================================
function! <SID>move_to_indent_block_scope_boundary(fwd, vim_mode) range
    let target_indent_depth = "<"
    let current_column = col('.')
    let nreps = v:count1
    let operational_first_line = a:firstline
    let operational_last_line = a:lastline
    if a:fwd
        let stepvalue = 1
    else
        let stepvalue = -1
    endif
    while nreps > 0
        let line_of_lowest_indent = operational_first_line
        let reference_indent = indent(line_of_lowest_indent)
        for lnr in range(operational_first_line, operational_last_line)
            let i = indent(lnr)
            if i < reference_indent
                let line_of_lowest_indent = lnr
                let reference_indent = i
            endif
        endfor
        " echomsg join([operational_first_line, operational_last_line, reference_indent], ", ")
        if reference_indent == 0
            " special case of 0-indent: any blank line is considered a block
            " boundary
            if a:fwd
                let current_line = operational_last_line
            else
                let current_line = operational_first_line
            endif
            let target_line = -1
            let last_line_of_buffer = line("$")
            let break_on_blank_line = 1
            " if a:fwd && strlen(getline(current_line + stepvalue)) == 0
            "     let break_on_blank_line = 0
            " endif
            let break_on_equal_indent = 0
            while (current_line > 0 && current_line <= last_line_of_buffer)
                let subsequent_line = current_line + stepvalue
                let subsequent_line_indent = indent(subsequent_line)
                if (a:fwd && subsequent_line_indent != reference_indent)
                    " When going forward (only), any line of 0 indent encountered
                    " after encountering lines of greater indent are considered the
                    " end of scope
                    let break_on_equal_indent = 1
                endif
                if (a:fwd && subsequent_line_indent > reference_indent) || (!a:fwd && subsequent_line_indent < reference_indent)
                    let break_on_blank_line = 0
                else
                    let is_subsequent_line_blank = strlen(getline(subsequent_line)) == 0
                    if (break_on_blank_line && is_subsequent_line_blank)
                                \ || (!is_subsequent_line_blank && break_on_equal_indent && subsequent_line_indent == reference_indent)
                        let target_line = current_line
                        break
                    endif
                endif
                let current_line += stepvalue
            endwhile
            break
        else
            " let target_line = s:_get_line_of_relative_indent(a:firstline, a:lastline, a:fwd, target_indent_depth, reference_indent, 1, v:count1)
            let target_line = s:_get_line_of_relative_indent(operational_first_line, operational_last_line, a:fwd, target_indent_depth, reference_indent, 1, 1)
        endif
        let nreps -= 1
        if target_line < 0
            break
        else
            let operational_first_line = target_line + stepvalue
            let operational_last_line = target_line + stepvalue
        endif
    endwhile

    if target_line < 0
        " no line located
        " figure out an alterate reasonable scope, falling back on file
        " boundaries if
        if a:fwd
            let fallback_line = line("$")
            let boundary_of_range = max([a:firstline, a:lastline])
            let stepvalue = 1
        else
            let fallback_line = 1
            let boundary_of_range = min([a:firstline, a:lastline])
            let stepvalue = -1
        endif

        let current_line = fallback_line
        let last_line_of_buffer = line("$")
        while (current_line > 0 && current_line <= last_line_of_buffer)
            if current_line == boundary_of_range || strlen(getline(current_line)) > 0
                let target_line = current_line
                break
            endif
            let current_line -= stepvalue
        endwhile
        if target_line < 0
            let target_line = fallback_line
        endif
    elseif a:fwd && strlen(getline(target_line)) == 0
        " && get(b:, "indentwise_skip_blanks", get(g:, "indentwise_skip_blanks", 1))
        " when going forward, we do not want to include blank lines
        " in current scope
        let fallback_line = target_line
        let stepvalue = 1
        let boundary_of_range = max([a:firstline, a:lastline])
        " if a:fwd
        "     let stepvalue = 1
        "     let boundary_of_range = max([a:firstline, a:lastline])
        " else
        "     let stepvalue = -1
        "     let boundary_of_range = min([a:firstline, a:lastline])
        " endif
        let current_line = fallback_line
        let last_line_of_buffer = line("$")
        while (current_line > 0 && current_line <= last_line_of_buffer)
            if current_line == boundary_of_range || strlen(getline(current_line)) > 0
                let target_line = current_line
                break
            endif
            let current_line -= stepvalue
        endwhile
    endif

    if a:vim_mode == "v"
        normal! gv
    endif
    if target_line > 0
        let preserve_col_pos = get(b:, "indentwise_preserve_col_pos", get(g:, "indentwise_preserve_col_pos", 0))
        if preserve_col_pos
            execute "normal! " . target_line . "G" . current_column . "|"
        else
            execute "normal! " . target_line . "G^"
        endif
    endif
endfunction
" 2}}}

" 1}}}

" Public Command and Key Maps {{{1
" ==============================================================================

nnoremap <silent> <Plug>(IndentWisePreviousLesserIndent)    :<C-U>call <SID>move_to_indent_depth(0,  "<", 0, "n")<CR>
vnoremap <silent> <Plug>(IndentWisePreviousLesserIndent)         :call <SID>move_to_indent_depth(0,  "<", 0, "v")<CR>
onoremap <silent> <Plug>(IndentWisePreviousLesserIndent)   V:<C-U>call <SID>move_to_indent_depth(0,  "<", 1, "o")<CR>

nnoremap <silent> <Plug>(IndentWisePreviousEqualIndent)     :<C-U>call <SID>move_to_indent_depth(0, "==", 0, "n")<CR>
vnoremap <silent> <Plug>(IndentWisePreviousEqualIndent)          :call <SID>move_to_indent_depth(0, "==", 0, "v")<CR>
onoremap <silent> <Plug>(IndentWisePreviousEqualIndent)    V:<C-U>call <SID>move_to_indent_depth(0, "==", 1, "o")<CR>

nnoremap <silent> <Plug>(IndentWisePreviousGreaterIndent)   :<C-U>call <SID>move_to_indent_depth(0,  ">", 0, "n")<CR>
vnoremap <silent> <Plug>(IndentWisePreviousGreaterIndent)        :call <SID>move_to_indent_depth(0,  ">", 0, "v")<CR>
onoremap <silent> <Plug>(IndentWisePreviousGreaterIndent)  V:<C-U>call <SID>move_to_indent_depth(0,  ">", 1, "o")<CR>

nnoremap <silent> <Plug>(IndentWiseNextLesserIndent)        :<C-U>call <SID>move_to_indent_depth(1,  "<", 0, "n")<CR>
vnoremap <silent> <Plug>(IndentWiseNextLesserIndent)             :call <SID>move_to_indent_depth(1,  "<", 0, "v")<CR>
onoremap <silent> <Plug>(IndentWiseNextLesserIndent)       V:<C-U>call <SID>move_to_indent_depth(1,  "<", 1, "o")<CR>

nnoremap <silent> <Plug>(IndentWiseNextEqualIndent)         :<C-U>call <SID>move_to_indent_depth(1, "==", 0, "n")<CR>
vnoremap <silent> <Plug>(IndentWiseNextEqualIndent)              :call <SID>move_to_indent_depth(1, "==", 0, "v")<CR>
onoremap <silent> <Plug>(IndentWiseNextEqualIndent)        V:<C-U>call <SID>move_to_indent_depth(1, "==", 1, "o")<CR>

nnoremap <silent> <Plug>(IndentWiseNextGreaterIndent)       :<C-U>call <SID>move_to_indent_depth(1,  ">", 0, "n")<CR>
vnoremap <silent> <Plug>(IndentWiseNextGreaterIndent)            :call <SID>move_to_indent_depth(1,  ">", 0, "v")<CR>
onoremap <silent> <Plug>(IndentWiseNextGreaterIndent)      V:<C-U>call <SID>move_to_indent_depth(1,  ">", 1, "o")<CR>

nnoremap <silent> <Plug>(IndentWisePreviousAbsoluteIndent)  :<C-U>call <SID>move_to_absolute_indent_level(0, 0, "n")<CR>
vnoremap <silent> <Plug>(IndentWisePreviousAbsoluteIndent)       :call <SID>move_to_absolute_indent_level(0, 0, "v")<CR>
onoremap <silent> <Plug>(IndentWisePreviousAbsoluteIndent) V:<C-U>call <SID>move_to_absolute_indent_level(0, 0, "o")<CR>

nnoremap <silent> <Plug>(IndentWiseNextAbsoluteIndent)      :<C-U>call <SID>move_to_absolute_indent_level(1, 0, "n")<CR>
vnoremap <silent> <Plug>(IndentWiseNextAbsoluteIndent)           :call <SID>move_to_absolute_indent_level(1, 0, "v")<CR>
onoremap <silent> <Plug>(IndentWiseNextAbsoluteIndent)     V:<C-U>call <SID>move_to_absolute_indent_level(1, 0, "o")<CR>

nnoremap <silent> <Plug>(IndentWiseBlockScopeBoundaryBegin)  :<C-U>call <SID>move_to_indent_block_scope_boundary(0, "n")<CR>
vnoremap <silent> <Plug>(IndentWiseBlockScopeBoundaryBegin)       :call <SID>move_to_indent_block_scope_boundary(0, "v")<CR>
onoremap <silent> <Plug>(IndentWiseBlockScopeBoundaryBegin) V:<C-U>call <SID>move_to_indent_block_scope_boundary(0, "o")<CR>

nnoremap <silent> <Plug>(IndentWiseBlockScopeBoundaryEnd)      :<C-U>call <SID>move_to_indent_block_scope_boundary(1, "n")<CR>
vnoremap <silent> <Plug>(IndentWiseBlockScopeBoundaryEnd)           :call <SID>move_to_indent_block_scope_boundary(1, "v")<CR>
onoremap <silent> <Plug>(IndentWiseBlockScopeBoundaryEnd)     V:<C-U>call <SID>move_to_indent_block_scope_boundary(1, "o")<CR>

if !exists("g:indentwise_suppress_keymaps") || !g:indentwise_suppress_keymaps
    if !hasmapto('<Plug>(IndentWisePreviousLesserIndent)')
        map [- <Plug>(IndentWisePreviousLesserIndent)
        sunmap [-
    endif
    if !hasmapto('<Plug>(IndentWisePreviousEqualIndent)')
        map [= <Plug>(IndentWisePreviousEqualIndent)
        sunmap [=
    endif
    if !hasmapto('<Plug>(IndentWisePreviousGreaterIndent)')
        map [+ <Plug>(IndentWisePreviousGreaterIndent)
        sunmap [+
    endif
    if !hasmapto('<Plug>(IndentWiseNextLesserIndent)')
        map ]- <Plug>(IndentWiseNextLesserIndent)
        sunmap ]-
    endif
    if !hasmapto('<Plug>(IndentWiseNextEqualIndent)')
        map ]= <Plug>(IndentWiseNextEqualIndent)
        sunmap ]=
    endif
    if !hasmapto('<Plug>(IndentWiseNextGreaterIndent)')
        map ]+ <Plug>(IndentWiseNextGreaterIndent)
        sunmap ]+
    endif
    if !hasmapto('<Plug>(IndentWisePreviousAbsoluteIndent)')
        map [_ <Plug>(IndentWisePreviousAbsoluteIndent)
        sunmap [_
    endif
    if !hasmapto('<Plug>(IndentWiseNextAbsoluteIndent)')
        map ]_ <Plug>(IndentWiseNextAbsoluteIndent)
        sunmap ]_
    endif
    if !hasmapto('<Plug>(IndentWiseBlockScopeBoundaryBegin)')
        map [% <Plug>(IndentWiseBlockScopeBoundaryBegin)
        sunmap [%
    endif
    if !hasmapto('<Plug>(IndentWiseBlockScopeBoundaryEnd)')
        map ]% <Plug>(IndentWiseBlockScopeBoundaryEnd)
        sunmap ]%
    endif

endif

" 1}}}

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" 1}}}

" vim:foldlevel=4:
