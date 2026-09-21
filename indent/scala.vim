vim9script

if exists('b:did_indent')
  finish
endif
b:did_indent = true

import autoload '../autoload/vim9scala3/indent.vim'

g:Vim9Scala3Indent = indent.Expr
setlocal autoindent
setlocal indentexpr=g:Vim9Scala3Indent()
setlocal indentkeys=o,O,!^F,0=else,0=catch,0=finally,0=yield,0=end

b:undo_indent = 'setlocal autoindent< indentexpr< indentkeys<'
    .. ' | unlet! b:did_indent b:vim9_scala3_lex_cache'
