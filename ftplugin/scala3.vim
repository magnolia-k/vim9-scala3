vim9script

# Filetype plugin for Scala 3

if v:version < 902
  finish
endif

if exists('b:did_ftplugin')
  finish
endif
b:did_ftplugin = true

# Comment settings
setlocal commentstring=//\ %s
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

# Indentation settings (Scala convention: 2 spaces)
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab

# File navigation
setlocal suffixesadd=.scala

# Matching pairs
setlocal matchpairs=(:),{:},[:]

# Format options
setlocal formatoptions-=t
setlocal formatoptions+=croqnlj

# Undo settings when switching filetype
b:undo_ftplugin = 'setlocal commentstring< comments< shiftwidth< softtabstop< expandtab< suffixesadd< matchpairs< formatoptions<'
